turtles-own
[
  in-team?     ;; true if an agent belongs to the new team being constructed
  union? ;;does the turtle want a union?
  buster? ;;does a turtle not want a union?
  match-change? ;; signifies if this turtle has had a link already added. fixes weird bug where both groups converge into one massive group, which doesn't work
]

links-own
[
  new-collaboration?  ;; true if the link represents the first time two agents collaborated
]


;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to make-newcomer
  create-turtles 1
  [
    set color blue + 1
    set size 1.8
    set in-team? false
    set union? false
    set buster? false
    set match-change? false
    set color blue
  ]
end


to setup
  clear-all
  set-default-shape turtles "circle"

  ;; assemble the first team
  repeat starting-turtles [ make-newcomer ]

  repeat 2 [
    ask one-of turtles [
      set union? true
      set buster? false
      set in-team? true
      set color green
    ]
  ]

  tie-collaborators
  color-collaborations

  ask turtles [
    set in-team? false
  ]

  repeat 2 [
  ask one-of turtles with [union? != true]
    [
      set union? false
      set buster? true
      set in-team? true
      set color yellow
    ]
  ]


  tie-collaborators
  color-collaborations

  ask turtles  ;; arrange turtles in a regular polygon
  [
    set heading (360 / 2) * who
    fd 1.75
    set in-team? false
  ]

  layout

  reset-ticks
end

to check-yeet
  if turtles with [union? = true] = NOBODY [
    print "there are no more unionizers"
    stop
  ]

  if turtles with [buster? = true] = NOBODY [
    print "there are no more union busters lol"
    stop
  ]

  ;;ask turtles [
  ;  if count links > 0 and union? = false and buster? = false [
  ;    show links
  ;    stop
  ;  ]
  ;]

  ;;print "checked"
end

;;;;;;;;;;;;;;;;;;;;;;;
;;; Main Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;

to go

  ;;;check-yeet

  if turtles with [union? = true] = NOBODY [
    print "there are no more unionizers, union loses"
    stop
  ]

  if count turtles with [union? = true] < 2 [
    print "there aren't enough pro-union turtles to proceed, union loses"
    stop
  ]

  ;;unions
  union-work

  if turtles with [buster? = true] = NOBODY [
    print "there are no more union busters lol, union wins"
    stop
  ]

  if count turtles with [buster? = true] < 2 [
    print "there aren't enough anti-union turtles to proceed, union wins"
    stop
  ]

  ;;busters
  buster-work

  ;; age turtles
  ask turtles
  [
    set in-team? false
  ]

  layout

  tick
end

;;causes random "friendships" to form, adding or removing people from the unionizers or busters
to union-work
  ;;;check-yeet

  ;;print "unions"
  ask one-of turtles with [union? = true and buster? = false] [
    ;;print self
    set in-team? true
    if random 100 < p [
      ;;;check-yeet
      ask one-of turtles with [union? = false and match-change? = false] [
        set match-change? true
        ifelse buster? = false [
          set union? true
          set in-team? true
          set color green
        ]
        [
          ask my-links [
            die
          ]
          set union? false
          set buster? false
          set color blue
        ]
      ]
    ]
  ]

  tie-collaborators
  color-collaborations

  ask turtles [
    set in-team? false
  ]

end

to buster-work

  ;;print "busters"
  ask one-of turtles with [union? = false and buster? = true] [
    ;;print self
    set in-team? true
    if random 100 < q [
      ;;;check-yeet
      ask one-of turtles with [buster? = false and match-change? = false] [
        set match-change? true
        ifelse union? = false [
          set buster? true
          set in-team? true
          set color yellow
        ]
        [
          ask my-links [
            die
          ]
          set union? false
          set buster? false
          set color blue
        ]
      ]
    ]
  ]

  tie-collaborators
  color-collaborations

  ask turtles [
    set in-team? false
    set match-change? false
  ]

  ;;;check-yeet


  ;;fixing issue where groups would fragment on a person leaving
  ;;ask turtles with [union? = true] [
  ;;  create-links-with other turtles with [union? = true]
  ;;]

  ;;;;;check-yeet

  ;;ask turtles with [buster? = true] [
  ;;  create-links-with other turtles with [buster?]
  ;;]

  ;;;check-yeet

end

;; forms a link between all unconnected turtles with in-team? = true
to tie-collaborators
  ask turtles with [in-team?]
  [
    create-links-with other turtles with [in-team?]
    [
      set new-collaboration? true  ;; specifies newly-formed collaboration between two members
      set thickness 0.3
    ]
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Visualization Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; color links according to past experience
to color-collaborations
    ask links with [[in-team?] of end1 and [in-team?] of end2]
    [
      ifelse new-collaboration?
      [
        ifelse ([union?] of end1) and ([union?] of end2)
        [
          set color green       ;; both members are union
        ]
        [
          ifelse ([buster?] of end1) and ([buster?] of end2)
            [ set color yellow ]   ;; both members are busters
            [ set color red ]
        ]
      ]
      [
        set color red            ;; members are previous collaborators
      ]
    ]
end

;; perform spring layout on all turtles and links
to layout
  repeat 12 [
    layout-spring turtles links 0.18 0.01 1.2
    display
  ]
end


; Copyright 2007 Uri Wilensky.
; See Info tab for full copyright and license.