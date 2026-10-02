var dx   = GetRightHeld() - GetLeftHeld();
var dy   = GetDownHeld()  - GetUpHeld();
var move = new Event("Move", {x: dx, y: dy});

entity.fireEvent(move);