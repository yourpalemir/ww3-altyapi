function canFly()
    return (getElementData(localPlayer,'adminlevel') >= 1)
end
  
  addCommandHandler("fly", function()
      if canFly() and getElementData(localPlayer, 'duty') == 1 then
          if not getPedOccupiedVehicle(localPlayer) then
              toggleAirBrake()
          end
      else
        outputChatBox("Bu komutu kullanabilmek için /aduty'de olman lazım.",255,255,255)
      end
  end)
  
  function putPlayerInPosition(timeslice)
      if isChatBoxInputActive() or isConsoleActive() then
          return
      end
      local cx,cy,cz,ctx,cty,ctz = getCameraMatrix()
      ctx,cty = ctx-cx,cty-cy
      timeslice = timeslice*0.1
      if not isConsoleActive() then
          if getKeyState("mouse1") then timeslice = timeslice*10 end
          if getKeyState("num_7") then timeslice = timeslice*4 end
          if getKeyState("num_9") then timeslice = timeslice*0.25 end
          if getKeyState("lshift") then timeslice = timeslice*1 end
          local mult = timeslice/math.sqrt(ctx*ctx+cty*cty)
          ctx,cty = ctx*mult,cty*mult
          if getKeyState("w") then
              abx,aby = abx+ctx,aby+cty
              local a = rotFromCam(0)
              setElementRotation(localPlayer,0,0,a)
          end
          if getKeyState("s") then
              abx,aby = abx-ctx,aby-cty
              local a = rotFromCam(180)
              setElementRotation(localPlayer,0,0,a)
          end
          if getKeyState("d") then
              abx,aby = abx+cty,aby-ctx
              local a = rotFromCam(90)
              setElementRotation(localPlayer,0,0,a)
          end
          if getKeyState("a") then
              abx,aby = abx-cty,aby+ctx
              local a = rotFromCam(-90)
              setElementRotation(localPlayer,0,0,a)
          end
          if getKeyState("space") then
              abz = abz+timeslice
          end
          if getKeyState("lctrl") then
              abz = abz-timeslice
          end
      end
          
      tempPos = abx, aby, abz
      setElementPosition(localPlayer,abx,aby,abz)
  end

  function toggleAirBrake()
      air_brake = not air_brake or nil
      if air_brake then
          abx,aby,abz = getElementPosition(localPlayer)
          setElementFrozen(localPlayer, true)
          setElementCollisionsEnabled(getLocalPlayer(),false)
          addEventHandler("onClientPreRender",root,putPlayerInPosition)
      else
          abx,aby,abz = nil
          setElementFrozen(localPlayer, false)
          setElementCollisionsEnabled(getLocalPlayer(),true)
          removeEventHandler("onClientPreRender",root,putPlayerInPosition)
      end
  end
  
  function rotFromCam(rzOffset)
      local cx,cy,_,fx,fy = getCameraMatrix(getLocalPlayer())
      local deltaY,deltaX = fy-cy,fx-cx
      local rotZ = math.deg(math.atan((deltaY)/(deltaX)))
      if deltaY >= 0 and deltaX <= 0 then
          rotZ = rotZ+180
      elseif deltaY <= 0 and deltaX <= 0 then
          rotZ = rotZ+180
      end
      return -rotZ+90 + rzOffset
  end