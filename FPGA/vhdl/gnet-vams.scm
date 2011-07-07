;;; gEDA - GPL Electronic Design Automation
;;; gnetlist - gEDA Netlist
;;; Copyright (C) 1998-2010 Ales Hvezda
;;; Copyright (C) 1998-2010 gEDA Contributors (see ChangeLog for details)
;;;
;;; This program is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 2 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program; if not, write to the Free Software
;;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; --------------------------------------------------------------------------
;;; 
;;;  VHDL-AMS netlist backend written by Eduard Moser and Martin Lehmann.
;;;  Build on the VHDL backend from Magnus Danielson
;;;
;;; --------------------------------------------------------------------------


;; Boiler-plate - load modules
(use-modules (ice-9 string-fun))
(use-modules (srfi srfi-13))

;;; ===================================================================================
;;;                  TOP LEVEL FUNCTION
;;;                        BEGIN

;;;   Write structural VAMS representation of the schematic

;;;   absolutly toplevel function of gEDA gnelist vams mode.
;;;   its evaluate things like output-file, generate-mode, top-attribs 
;;;   and starts the major subroutines.  

;; guile didn't like this code:
;;
;; (if (string-index output-filename #\.) 
;;    (string-rindex output-filename #\.) 
;;   ofl)
;; 
;; as a replacement for line below:
;;
;; (lpi (string-rindex output-filename #\. 0 ofl))
;;
;; why? (avh)

(define vams
  (lambda (output-filename)
    (let* ((port '())                         ;; write-destination for architecture
	   (port-entity '())                  ;; write-destination for entity
	   (ofl (string-length output-filename))            
	   (lpi (string-rindex output-filename #\. 0 ofl))

	   ;; generate correctly architecture name
	   (architecture (vams:change-all-whitespaces-to-underlines 
			  (cond 
			   ((string=? 
			     (gnetlist:get-toplevel-attribute "architecture") 
			     "not found") "default_architecture")
			   (else  
			    (gnetlist:get-toplevel-attribute "architecture")))))

	   ;; generate correctly entity name
	   (entity (vams:change-all-whitespaces-to-underlines 
		    (cond ((string=? 
			    (gnetlist:get-toplevel-attribute "entity") 
			    "not found") 
			   "default_entity")
			  (else (gnetlist:get-toplevel-attribute "entity")))))

	   ;; search all ports of a schematic. for entity generation only.
	   (port-list  (vams:generate-port-list (vams:get-uref top-attribs)))
	   
	   ;; search all generic of a schematic. for entity generatin only.
	   (generic-list (vams:generate-generic-list top-attribs)))
      

      ;; generate-mode : 1 (default) -> generate a architecture (netlist) of a 
      ;;                                schematic 
      ;;                 2           -> is selected a component then generate
      ;;                                a entity of this, else generate
      ;;                                a toplevel entity. called from gschem  
      ;;                                normally.

      (cond ((= generate-mode 1)
	     (begin
	       (display "\ngenerating architecture of current schematic in ")

	       ;; generate output-filename, like
	       ;; (<entity>_arc.<output-file-extension>)
               (set! output-filename 
                (string-append
                 (if (string-index output-filename #\/)
                     (substring output-filename 0
                                (+ (string-rindex 
                                    output-filename #\/ 0 ofl) 1))
                     "./")
                 (string-downcase! entity)
                 "_arc"
                 (substring output-filename lpi ofl)))

	       (set!  port (open-output-file output-filename))
	       (display output-filename)
	       (newline)
	       (display "-- Structural VAMS generated by gnetlist\n" port)
	       (vams:write-secondary-unit architecture entity  port)
	       (close-output-port port)))
	    
	    ((= generate-mode 2)
	     (display "\n\ngenerating entity of current schematic in ")
	     
	     ;; if one component selected, then generate output-filename 
	     ;; (<device of selected component>.vhdl), else 
	     ;; <entity>.vhdl
	     (if (not (null? top-attribs))
		 (set! output-filename 
		       (string-append 
                        (if (string-index output-filename #\/)
			   (substring output-filename 0
				   (+ (string-rindex 
				       output-filename #\/ 0 ofl) 1))
                            "./")
			(string-downcase! 
			 (get-device (vams:get-uref top-attribs)))
			".vhdl"))
		 (set! output-filename 
		       (string-append 
                        (if (string-index output-filename #\/)
			   (substring output-filename 0
				   (+ (string-rindex 
				       output-filename #\/ 0 ofl) 1))
                            "./")
			(string-downcase! entity)
			".vhdl")))
		 
	     (display output-filename)
	     (newline)
	     (set! port-entity (open-output-file output-filename))
	     	     
	     ;; decide about the right parameters for entity-declaration
	     (if (not (null? (vams:get-uref top-attribs)))
		 (vams:write-primary-unit (get-device (vams:get-uref top-attribs))
					  port-list 
					  generic-list port-entity)
		 (vams:write-primary-unit  entity port-list generic-list
					   port-entity))
	     
	     (close-output-port port-entity))))))


;;;                  TOP LEVEL FUNCTION
;;;                        END

;;; ===================================================================================

;;;
;;;              ENTITY GENERATING PART
;;;                     BEGIN


;;; Context clause
;;;
;;; According to IEEE 1076-1993 11.3:
;;;
;;; context_clause := { context_item }
;;; context_item := library_clause | use_clause
;;;
;;; Implementation note:
;;;    Both library and use clauses will be generated, eventually...
;;;    What is missing is the information from gEDA itself, i think.


;;; writes some needed library insertions staticly 
;;; not really clever, but a first solution

(define vams:write-context-clause
  (lambda (p)
    (display "LIBRARY ieee,disciplines;\n" p)
    (display "USE ieee.math_real.all;\n" p)
    (display "USE ieee.math_real.all;\n" p)
    (display "USE work.electrical_system.all;\n" p)
    (display "USE work.all;\n" p)))



;;; Primary unit
;;;
;;; According to IEEE 1076-1993 11.1:
;;;
;;; primary_unit :=
;;;    entity_declaration
;;;  | configuration_declaration
;;;  | package_declaration
;;;
;;; Implementation note:
;;;    We assume that gEDA does not generate either a configuration or
;;;    package declaration. Thus, only a entity declaration will be generated.
;;;
;;; According to IEEE 1076-1993 1.1:
;;;
;;; entity_declaration :=
;;;    ENTITY identifier IS
;;;       entity_header
;;;       entity_declarative_part
;;;  [ BEGIN
;;;       entity_statement_part ]
;;;    END [ ENTITY ] [ entity_simple_name ] ;
;;;
;;; Implementation note:
;;;    We assume that no entity declarative part and no entity statement part
;;;    is to be produced. Further, it is good custom in VAMS-93 to append
;;;    both the entity keyword as well as the entity simple name to the
;;;    trailer, therefore this is done to keep VAMS compilers happy.
;;;
;;; According to IEEE 1076-1993 1.1.1:
;;;
;;; entity_header :=
;;;  [ formal_generic_clause ]
;;;  [ formal_port_clause ]
;;;
;;; Implementation note:
;;;    Initially we will assume that there is no generic clause but that there
;;;    is an port clause. We would very much like to have generic and the port
;;;    clause should be conditional (consider writting a test-bench).


;;; this routine managed the complete entity-declaration of a component 
;;; or a schematic. It requires the entity-name, all ports and generics
;;; of this entity and the write-destination the write-destination defines where
;;; this all should wrote to.

(define vams:write-primary-unit
  (lambda (entity port-list generic-list p)
    (begin
      (vams:write-context-clause p)
      (display "-- Entity declaration -- \n\n" p)
      (display "ENTITY " p)
      (display entity p)
      (display " IS\n" p)
      (vams:write-generic-clause generic-list p)
      (vams:write-port-clause port-list p)
      (display "END ENTITY " p)
      (display entity p)
      (display "; \n\n" p))))

;;; GENERIC & PORT Clause
;;;
;;; According to IEEE 1076-1993 1.1.1:
;;;
;;; entity_header :=
;;;  [ formal_generic_clause ]
;;;  [ formal_port_clause ]
;;;
;;; generic_clause :=
;;;    GENERIC ( generic_list ) ;
;;;
;;; port_clause :=
;;;    PORT ( port_list ) ;
;;;
;;; According to IEEE 1076-1993 1.1.1.2:
;;;
;;; port_list := port_interface_list
;;;
;;; According to IEEE 1076-1993 4.3.2.1:
;;;
;;; interface_list := interface_element { ; interface_element }
;;;
;;; interface_element := interface_declaration
;;;
;;; According to IEEE 1076-1993 4.3.2:
;;;
;;; interface_declaration :=
;;;    interface_constant_declaration
;;;  | interface_signal_declaration
;;;  | interface_variable_declaration
;;;  | interface_file_declaration
;;;
;;; interface_signal_declaration :=
;;;  [ SIGNAL ] identifier_list : [ mode ] subtype_indication [ BUS ]
;;;  [ := static_expression ]
;;;
;;; mode := IN | OUT | INOUT | BUFFER | LINKAGE
;;;
;;; Implementation note:
;;;    Since the port list must contain signals will only the interface
;;;    signal declaration of the interface declaration be valid. Further,
;;;    we may safely assume that the SIGNAL symbol will not be needed.
;;;    The identifier list is reduced to a signle name entry, mode is set
;;;    to in, out or inout due to which part of the port list it comes from.
;;;    The mode types supported are in, out and inout where as buffer and
;;;    linkage mode is not supported. The subtype indication is currently
;;;    hardwired to standard logic, but should be controlled by attribute.
;;;    There is currently no support for busses and thus is the BUS symbol
;;;    no being applied. Also, there is currently no static expression
;;;    support, this too may be conveyed using attributes.


;;; these next two functions write the generic-clause 
;;; in the entity declaration
;;; vams:write-generic-clause requires a list of all generics and
;;; their values, such as (("power:REAL" 12.2) ("velocity:REAL" 233.34))


(define vams:write-generic-clause
  (lambda (gens p)
    (if (not (null? gens))
	(begin
	  (display "\t GENERIC (" p)
	  (display "\t" p)
	  (vams:gen-declare (caar gens) (cadar gens) p)
	  (for-each
	    (vams:uncurry
	      (lambda (att val)
	        (begin
                  (display ";\n\t\t\t" p)
	          (vams:gen-declare att val p))))
	    (cdr gens))
	  (display " );\n" p))
	  (display "\t--No Generics\n" p))))


(define vams:gen-declare
  (lambda (att val p)
    (begin
      (display att p)
      (display " := " p)
      (if (string-prefix=? "?" val)
          (display (substring val 1) p)
          (display val p)))))


;;; this function writes the port-clause in the entity-declarartion
;;; It requires a list of ports. ports stand for a list of all
;;; pin-attributes.

(define vams:write-port-clause
  (lambda (port-list p)
    (if (not (null? port-list))
	(begin
	  (display "\t PORT (\t" p)
	  (display "\t" p)
	  (if (list? (car port-list))
	      (begin
		(display (cadar port-list) p) 
		(display " \t" p)
		(display (caar port-list) p)
		(display " \t: " p)
		(display (car (cdddar port-list)) p)
		(display " \t" p)
		(display (caddar port-list) p)))
	  (vams:write-port-list (cdr port-list) p)
	  (display " );\n" p)))))

;;; This little routine writes a single pin on the port-clause.
;;; It requires a list containing (port_name, port_object, port_type, port_mode)
;;; such like
;;; ((heat quantity thermal in) (base terminal electrical unknown) .. )

(define vams:write-port-list
  (lambda (port-list p)
    (if (not (null? port-list))
	(begin
	  (display ";\n\t\t\t" p)
	  (if (equal? (length (car port-list)) 4)
	      (begin
		(display (cadar port-list) p) 
		(display " \t" p)
		(display (caar port-list) p)
		(display " \t: " p)
                ; No such thing as "cadddar"
		(display (car (cdddar port-list)) p)
		(display " \t" p)
		(display (caddar port-list) p)))
	  (vams:write-port-list (cdr port-list) p)))))



;;;              ENTITY GENERATING PART
;;;                     END

;;; ===================================================================================

;;;           ARCHITECTURE GENERATING PART
;;;                   BEGIN



;; Secondary Unit Section
;;

;;; Architecture Declarative Part
;;;
;;; According to IEEE 1076-1993 1.2.1:
;;;
;;; architecture_declarative_part :=
;;;  { block_declarative_item }
;;;
;;; block_declarative_item :=
;;;    subprogram_declaration
;;;  | subprogram_body
;;;  | type_declaration
;;;  | subtype_declaration
;;;  | constant_declaration
;;;  | signal_declaration
;;;  | shared_variable_declaration
;;;  | file_declaration
;;;  | alias_declaration
;;;  | component_declaration
;;;  | attribute_declaration
;;;  | attribute_specification
;;;  | configuration_specification
;;;  | disconnection_specification
;;;  | use_clause
;;;  | group_template_declaration
;;;  | group_declaration
;;;
;;; Implementation note:
;;;    There is currently no support for programs or procedural handling in
;;;    gEDA, thus will all declarations above involved in thus activites be
;;;    left unused. This applies to subprogram declaration, subprogram body,
;;;    shared variable declaration and file declaration.
;;;
;;;    Further, there is currently no support for type handling and therefore
;;;    will not the type declaration and subtype declaration be used.
;;;
;;;    The is currently no support for constants, aliases, configuration
;;;    and groups so the constant declaration, alias declaration, configuration
;;;    specification, group template declaration and group declaration will not
;;;    be used.
;;;
;;;    The attribute passing from a gEDA netlist into VAMS attributes must
;;;    wait, therefore will the attribute declaration and attribute
;;;    specification not be used.
;;;
;;;    The disconnection specification will not be used.
;;;
;;;    The use clause will not be used since we pass the responsibility to the
;;;    primary unit (where it �s not yet supported).
;;;
;;;    The signal declation will be used to convey signals held within the
;;;    architecture.
;;;
;;;    The component declaration will be used to convey the declarations of
;;;    any external entity being used within the architecture.


;;; toplevel-subfunction for architecture generation.
;;; requires architecture and entity name and the port, where
;;; the architecture should wrote to.

(define vams:write-secondary-unit
  (lambda (architecture entity p)
    (display "-- Secondary unit\n\n" p)
    (display "ARCHITECTURE " p)
    (display architecture p)
    (display " OF " p)
    (display entity p)
    (display " IS\n" p)
    (vams:write-architecture-declarative-part p)
    (display "BEGIN\n" p)
    (vams:write-architecture-statement-part packages p)
    (display "END ARCHITECTURE " p)
    (display architecture p)
    (display ";\n" p)))

;;; 
;;; at this time, it only calls the signal declarations

(define vams:write-architecture-declarative-part
  (lambda (p)
    (begin
      ; Due to my taste will the component declarations go first
      ; XXX - Broken until someday
      ; (vams:write-component-declarations packages p)
      ; Then comes the signal declatations
      (vams:write-signal-declarations p))))


;;; Signal Declaration
;;;
;;; According to IEEE 1076-1993 4.3.1.2:
;;;
;;; signal_declaration :=
;;;    SIGNAL identifier_list : subtype_indication [ signal_kind ]
;;;    [ := expression ] ;
;;;
;;; signal_kind := REGISTER | BUS
;;;
;;; Implementation note:
;;;    Currently will the identifier list be reduced to a single entry.
;;;    There is no support for either register or bus type of signal kind.
;;;    Further, no default expression is being supported.
;;;    The subtype indication is hardwired to Std_Logic.


;;; the real signal-declaration-writing function
;;; it's something more complex, because it's checking all signals
;;; for consistency. it only needs the write-destination as parameter.

(define vams:write-signal-declarations
  (lambda (p)
    (begin 
      (for-each
       (lambda (net)
	 (let* ((connlist (gnetlist:get-all-connections net))
	        (port_object (vams:net-consistence "port_object" connlist))
	        (port_type (vams:net-consistence "port_type" connlist)))
	   (if (and port_object port_type)
	       (begin
		 (display "\t" p)
		 (if (or (equal? port_object "unknown") (null? port_object))
                     (display "signal" p)
		     (display port_object p))
		 (display " " p)
		 (display net p)
		 (display " \t: " p)
		 (display " " p)
		 (display port_type p)
		 (display ";\n" p))
	       (begin
		 (display "-- error in subnet : " p)
		 (display net p)
		 (newline p)))))
       (vams:all-necessary-nets)))))

;;; Architecture Statement Part
;;;
;;; According to IEEE 1076-1993 1.2.2:
;;;
;;; architecture_statement_part :=
;;;  { concurrent_statement }
;;;
;;; According to IEEE 1076-1993 9:
;;;
;;; concurrent_statement :=
;;;    block_statement
;;;  | process_statement
;;;  | concurrent_procedure_call_statement
;;;  | concurrent_assertion_statement
;;;  | concurrent_signal_assignment_statement
;;;  | component_instantiation_statement
;;;  | generate_statement
;;;
;;; Implementation note:
;;;    We currently does not support block statements, process statements,
;;;    concurrent procedure call statements, concurrent assertion statements,
;;;    concurrent signal assignment statements or generarte statements.
;;;
;;;    Thus, we only support component instantiation statements.
;;;
;;; According to IEEE 1076-1993 9.6:
;;;
;;; component_instantiation_statement :=
;;;    instantiation_label : instantiation_unit
;;;  [ generic_map_aspect ] [ port_map_aspect ] ;
;;;
;;; instantiated_unit :=
;;;    [ COMPONENT ] component_name
;;;  | ENTITY entity_name [ ( architecture_identifier ) ]
;;;  | CONFIGURATION configuration_name
;;;
;;; Implementation note:
;;;    Since we are not supporting the generic parameters we will thus not
;;;    suppport the generic map aspect. We will support the port map aspect.
;;;
;;;    Since we do not yeat support the component form we will not yet use
;;;    the component symbol based instantiated unit.
;;;
;;;    Since we do not yeat support configurations we will not support the
;;;    we will not support the configuration symbol based form.
;;;
;;;    This leaves us with the entity form, which we will support initially
;;;    using only the entity name. The architecture identifier could possibly
;;;    be supported by attribute value.

;;; Component Declaration
;;;
;;; According to IEEE 1076-1993 4.5:
;;;
;;; component_declaration :=
;;;    COMPONENT identifier [ IS ]
;;;     [ local_generic_clause ]
;;;     [ local_port_clause ]
;;;    END COMPONENT [ component_simple_name ] ;
;;;
;;; Implementation note:
;;;    The component declaration should match the entity declaration of the
;;;    same name as the component identifier indicates. Since we do not yeat
;;;    support the generic clause in the entity declaration we shall not
;;;    support it here either. We will however support the port clause.
;;;
;;;    In the same fassion as before we will use the conditional IS symbol
;;;    as well as replicating the identifier as component simple name just to
;;;    be in line with good VAMS-93 practice and keep compilers happy.

;;; Writes the architecture body.
;;; required all used packages, which are necessary for netlist-
;;; generation, and the write-destination

(define vams:write-architecture-statement-part
  (lambda (packages p)
    (begin
      (display "-- Architecture statement part\n\n" p)
      (display "-- Component connections\n" p)
      (for-each (lambda (package) (vams:write-arc-entity package p))
		(vams:all-necessary-packages)))))

;; Writes an entity with appropriate connections within an entity declaration
;; requires a package and a write-destination

(define vams:write-arc-entity
  (lambda (package p)
    (let ((architecture (gnetlist:get-package-attribute package "architecture")))
         (begin
           (display " \n  " p)
           ;; writes instance-label
           (display package p)
           (display " : ENTITY " p)
           ;; writes entity name, which should instantiated
           (display (get-device package) p)
           ;; write the architecture of an entity in brackets after
           ;; the entity, when necessary.
           (if (not (equal? architecture "unknown"))
               (begin
                 (display "(" p)
                   (if (equal? (string-ref architecture 0) #\?)
                       (display (substring architecture 1) p)
                       (display architecture p))
                 (display ")" p)))  
           (newline p)
           ;; writes generic map
           (vams:write-generic-map package p)
           ;; writes port map
           (vams:write-port-map package p)
           (display ";\n" p)))))


;; Get all package attribute-value pairs
(define vams:get-av-pairs
  (lambda (uref) 
    (map 
      (lambda (att) 
              (list att 
	           (gnetlist:get-package-attribute uref att)))
	      (gnetlist:vams-get-package-attributes uref))))

;; Get all top-level attribute-value pairs from a list of top-level attributes
(define vams:get-top-av-pairs
  (lambda (top-atts)
    (map (lambda (att) (list att 
                             (gnetlist:get-toplevel-attribute att)
                       ))
         top-atts)))

;; Given a uref, prints all generics attribute => values
;; requires the write-destination and a uref 

(define vams:write-generic-map 
  (lambda (uref p)
    (let ((gens (vams:all-used-generics 
                  (vams:get-av-pairs uref))))
      (if (not (null? gens))
	  (begin
	    (display "\tGENERIC MAP (\n" p)
	    (vams:write-component-attributes gens p)
	    (display ")\n" p))))))


;;; Port map aspect
;;;
;;; According to IEEE 1076-1993 5.6.1.2:
;;;
;;; port_map_aspect := PORT MAP ( port_association_list )
;;;
;;; According to IEEE 1076-1993 4.3.2.2:
;;;
;;; association_list :=
;;;    association_element { , association_element }

;;; writes the port map of the component.
;;; required write-destination and uref.

(define vams:write-port-map
  (lambda (uref p)
    (begin
      (let ((pin-list (gnetlist:get-pins-nets uref)))
	(if (not (null? pin-list))
	    (begin
	      (display "\tPORT MAP (\t" p)
	      (vams:write-association-element (car pin-list) p)
	      (for-each (lambda (pin)
			  (display ",\n" p)
			  (display "\t\t\t" p)
			  (vams:write-association-element pin p))
			(cdr pin-list))
	      (display ")" p)))))))


;;; Association element
;;;
;;; According to IEEE 1076-1993 4.3.2.2:
;;;
;;; association_element :=
;;;  [ formal_part => ] actual_part
;;;
;;; formal_part :=
;;;    formal_designator
;;;  | function_name ( formal_designator )
;;;  | type_mark ( formal_designator )
;;;
;;; formal_designator :=
;;;    generic_name
;;;  | port_name
;;;  | parameter_name
;;;
;;; actual_part :=
;;;    actual_designator
;;;  | function_name ( actual_designator )
;;;  | type_mark ( actual_designator )
;;;
;;; actual_designator :=
;;;    expression
;;;  | signal_name
;;;  | variable_name
;;;  | file_name
;;;  | OPEN
;;;
;;; Implementation note:
;;;    In the association element one may have a formal part or relly on
;;;    positional association. The later is doomed out as bad VAMS practice
;;;    and thus will the formal part allways be present.
;;;
;;;    The formal part will not support either the function name or type mark
;;;    based forms, thus only the formal designator form is supported.
;;;
;;;    Of the formal designator forms will generic name and port name be used
;;;    as appropriate (this currently means that only port name will be used).
;;;
;;;    The actual part will not support either the function name or type mark
;;;    based forms, thus only the actual designator form is supported.


;;; the purpose of this function is very easy: write OPEN if pin 
;;; unconnected and normal output if it connected.
 
(define vams:write-association-element
  (lambda (pin p)
    (begin
      (display (car pin) p)
      (display " => " p)
      (if (strncmp? (cdr pin) "unconnected_pin" 15)
	  (display "OPEN" p)
	  (display (vams:port-test pin) p)))))

;;; writes a generics declaration of a component into the
;;; generic map.
;;; Requires a generic/value pair.

(define vams:write-comp
  (lambda (att val p)
          (begin
	    (display "\t\t\t" p)
	    ; Thow away the type declaration on these thingies
	    (display (car (split-before-char #\: att list)) p)  
            (display " => " p)
	    (display val p))))

;;; writes all generics of a component into the
;;; generic map. needs components uref, the generic-list and
;;; an write-destination

(define vams:write-component-attributes 
 (lambda (gens p)
   (if (not (null? gens))
	 (begin
           (apply (lambda (att val) (vams:write-comp att val p)) (car gens)) 
	   (if (not (null? (cdr gens)))
	       (begin
		 (display ", " p)
		 (newline p)
		 (vams:write-component-attributes (cdr generic-list) p)))))))


;;;           ARCHITECTURE GENERATING PART
;;;                       END

;;; ===================================================================================

;;;
;;;           REALLY IMPORTANT HELPER FUNCTIONS

;; Identifies whether a component represents a top level port 
;; requires a component

(define vams:top-port? 
  (lambda (package)
    (any (lambda (port) (equal? (get-device package) port))
          '("IOPAD" "IPAD" "OPAD" "HIGH" "LOW" "PORT"))))


;; Takes a list of packages and yields the components 
;; representing ports of a top-level entity
;; requires a package list

(define vams:top-ports
  (lambda (package-list) (filter vams:top-port? package-list)))


;; Takes a list of packages and yields the components
;; that DO NOT represent ports of a top-level entity
;; requires a pakcage list

(define vams:not-ports 
  (lambda (package-list) (filter (vams:B not vams:top-port?) package-list)))


;; Checks whether an attribute of a uref is a VHDL generic
;; this is true just in case that attribute has ":" as a substring

(define vams:generic?
  (lambda (l v) (string-contains l ":")))


;; Checks whether an attribute of a uref is a VHDL generic
;; assigned to a default value
;; this is the case when the values starts with a '?' - character.

(define vams:default-generic?
  (lambda (l v) (and (vams:generic? l v) 
                     (string-prefix=? "?" v))))


;; Returns all none default-assigned generics
;; After our definitions, all attribs containing the substring ":" 
;; (indicating a VHDL type declaration), 

(define vams:all-used-generics
  (lambda (ls)
    (filter 
      (vams:uncurry
        (lambda (att val) 
          (and (vams:generic? att val) (not (vams:default-generic? att val)))))
      ls)))


;; checks an attribute on all pins of a net for consistence
;; requires: a pin-attribute and the subnet 

(define vams:net-consistence   
  (lambda (att connlist)
    (let* ((ls 
             ((@ (srfi srfi-1) delete-duplicates)
               (map (vams:uncurry 
                      (lambda (uref pin) 
                        (string-downcase 
                          (gnetlist:get-attribute-by-pinnumber uref pin att)))) 
                     connlist))))
          ; try to get the relevant attribute from all the pins
          ; if it's unique, then return the value, otherwise fail
          (if (equal? (length ls) 1) (car ls) #f))))


;; returns a string, where are all whitespaces replaced to underlines
;; requires: a string only

(define vams:change-all-whitespaces-to-underlines
  (lambda (str)
    (begin
      (if (string-index str #\ )
	  (begin
	    (if (= (string-index str #\ ) (- (string-length str) 1))
		(vams:change-all-whitespaces-to-underlines
		 (substring str 0 (- (string-length str) 1)))
		(begin
		  (string-set! str (string-index str #\ ) #\_ )
		  (vams:change-all-whitespaces-to-underlines str))))
	  (append str)))))


;; returns all nets, which a given list of pins are conneted to.
;; requires: uref and its pins

(define vams:all-pins-nets
  (lambda (uref pins)
    (if (null? pins)
	'()
	(append (list (car (gnetlist:get-nets uref (car pins))))
		(vams:all-pins-nets uref (cdr pins))))))


;; returns all nets, which a given list of urefs are connetd to
;; requires: list of urefs :-)

(define vams:all-packages-nets
  (lambda (urefs)
    (if (null? urefs)
	'()
	(append 
	 (vams:all-pins-nets (car urefs) 
			     (gnetlist:get-pins (car urefs)))
	 (vams:all-packages-nets (cdr urefs))))))


;; returns all nets in the schematic, which not 
;; directly connected to a port.
;; requires nothing

(define vams:all-necessary-nets
  (lambda ()
    (lset-difference equal? all-unique-nets 
                            (vams:all-packages-nets 
                              (vams:top-ports packages)))))


;; sort all port-components out
;; requires nothing

(define vams:all-necessary-packages
  (lambda () 
    (lset-difference equal? packages (vams:top-ports packages))))



;; if pin connected to a port (special component), then return port.
;; else return the net, which the pin is connected to. 
;; requires: a pin only

(define vams:port-test
  (lambda (pin)
    (if (member (cdr pin) 
		(vams:all-packages-nets (vams:top-ports packages)))
	(append (vams:which-port 
		 pin
		 (vams:top-ports packages)))
	(append (cdr pin)))))



;; returns the port, when is in port-list, which the pin is connected to
;; requires: a pin and a port-list

(define vams:which-port
  (lambda (pin ports)
    (begin
       (if (null? ports)
	  '()
	  (if (equal? (cdr pin) 
		      (car (gnetlist:get-nets 
		       (car ports) 
		       (car (gnetlist:get-pins (car ports))))))
	      (append (car ports))
	      (append 
	       (vams:which-port pin (cdr ports))))))))



;; generate generic list for generic clause 
;;((generic value) (generic value) .. ())
;; requires a list of urefs

(define vams:generate-generic-list
  (lambda (urefs)
    (filter (vams:uncurry vams:default-generic?)
            (if (null? urefs)
                (vams:get-top-av-pairs (gnetlist:vams-get-toplevel-attributes))
                (apply append (map vams:get-av-pairs myrefs))))))

;;; Generates a port list of the current schematic

(define vams:generate-port-list
  (lambda (uref)
    (map (vams:uncurry vams:pin-to-port)
         (if (null? uref)
             ; If uref is empty, try to infer ports from pin components,
             ; inspired by the SPICE gnetlister
             (apply append 
               (map vams:uref-pins (vams:top-ports packages)))
             ; Legacy mode for compatability
             (vams:uref-pins-legacy uref)))))

;; Takes a uref as input and outputs a list of uref/pin-numbers pairs
;; where the pin-numbers correspond to pins on the component for the uref

(define vams:uref-pins
  (lambda (uref) 
    (map (lambda (pin) (list uref pin uref))
         (gnetlist:get-pins uref))))



;; Old fashioned version of uref-pins for legacy mode

(define vams:uref-pins-legacy
  (lambda (uref) 
    (map (lambda (pin) (list uref pin pin))
         (gnetlist:get-pins uref))))



;; Takes a pin as input and yields a port 

(define vams:pin-to-port
  (lambda 
    (uref pin label) 
    (let* ((get-att 
             (lambda (att) 
               (string-downcase! 
                 (gnetlist:get-attribute-by-pinnumber uref pin att))))
           (port_objectp (get-att "port_object"))
           (port_object (if (equal? port_objectp "unknown") 
                            "" 
                            port_objectp))
           (port_type (get-att "port_type"))
           (port_mode (get-att "port_mode")))
    (list label port_object port_type port_mode))))



;; Gets matching urefs
;; (basically cloned from VHDL gnetlister, except purely functional)
(define vams:get-matching-urefs 
  (lambda (attribute value package-list)
    (filter 
      (lambda (cmp) 
              (string=? (gnetlist:get-package-attribute cmp attribute)
                        value))
      package-list)))



;;; gets the uref value from the top-attribs-list, which is assigned from gschem.
;;; only important for automatic-gnetlist-calls from gschem !!! 

(define vams:get-uref
  (lambda (liste)
    (begin
      (if (null? liste)
	  '()
	  (if (string-prefix=? "refdes=" (symbol->string (car liste)))
	      (begin
		(append (substring (car liste) 5 
				   (string-length (car liste)))))
	      (vams:get-uref (cdr liste)))))))



;; ====== Higher Order Helper Functions ======
;; These are higher order functions, which are mostly standard in
;; in other functional programming languages like Haskell/OCaml/Clojure
;; They are rarely used in Scheme (mpwd)

;; Composes two functions; same as the higher order function (.) in Haskell
;; Named "B" following Schonfinkle's 1924 paper 
;; "Uber die Bausteine der mathematischen Logik" where this combinator was introduced
;; requires two functions

(define vams:B (lambda (f g) (lambda (x) (f (g x)))))



;; "UnCurry"s a function - similar to higher order Haskell function of same name
;; Requires a function

(define vams:uncurry
  (lambda (fun) (lambda (args) (apply fun args))))



;; Another form of "UnCurry" - works on dotted pairs instead of lists.
;; Dotted pairs are more analogous to the product type in typed functional 
;; programming than lists, so this is more theoretically purist
;; Requires a function.  Arguably concepts from domain theory aren't 
;; applicable to a programming language based on the Untyped lambda calculus
;; Requires a function

(define vams:uncurry.
  (lambda (fun) (lambda (x) (fun (car x) (cdr x)))))

;; ====== Main Program ======

;;; set generate-mode to default (1), when not defined before.

(if (not (defined? 'generate-mode)) (define generate-mode '1))


;;; set to-attribs list empty, when not needed.
(if (not (defined? 'top-attribs)) (define top-attribs '()))


(display "loaded gnet-vams.scm\n")
