module Example4 where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import System.Clock (CLOCK, milliseconds)
import Data.Maybe (Maybe(Just, Nothing))
-- import Data.Array (concatMap, concat)
-- import Math (pi)
import Data.Int (toNumber)

import Graphics.WebGLAll (Attribute, Buffer, BufferTarget(ELEMENT_ARRAY_BUFFER), Capacity(DEPTH_TEST), EffWebGL, Mask(DEPTH_BUFFER_BIT, COLOR_BUFFER_BIT), Mat4, Mode(TRIANGLES), Shaders(Shaders), Uniform, Vec3, WebGLContext, WebGLProg, bindBuf, bindBufAndSetVertexAttr, clear, clearColor, drawArr, drawElements, enable, getCanvasHeight, getCanvasWidth, makeBuffer, makeBufferFloat, requestAnimationFrame, runWebGL, setUniformFloats, viewport, withShaders)
import Data.Matrix4 (identity, translate, rotate, makePerspective) as M
import Data.Matrix (toArray) as M
import Data.Vector3 as V3
import Control.Monad.Eff.Alert (Alert, alert)
import Data.ArrayBuffer.Types (Uint16, Float32) as T
import Data.TypedArray (asUint16Array) as T

-- My imports 
import Math (pi,sin,cos) 
import Data.Array (length,concat, concatMap, (..), (:))
-- import Data.Maybe (fromMaybe)

shaders :: Shaders {aVertexPosition :: Attribute Vec3, aVertexColor :: Attribute Vec3,
                      uPMatrix :: Uniform Mat4, uMVMatrix:: Uniform Mat4}
shaders = Shaders

  """precision mediump float;

  varying vec4 vColor;

  void main(void) {
    gl_FragColor = vColor;
      }
  """

  """
      attribute vec3 aVertexPosition;
      attribute vec4 aVertexColor;

      uniform mat4 uMVMatrix;
      uniform mat4 uPMatrix;

      varying vec4 vColor;

      void main(void) {
          gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
          vColor = aVertexColor;
      }
  """

type State = {
                context :: WebGLContext,
                shaderProgram :: WebGLProg,
                aVertexPosition :: Attribute Vec3,
                aVertexColor  :: Attribute Vec3,
                uPMatrix :: Uniform Mat4,
                uMVMatrix :: Uniform Mat4,
                -- sphereVerticies ::Buffer T.Float32,
                -- sphereColours :: Buffer T.Float32,
                -- sphereVertexIndices :: Buffer T.Uint16,
                pyramidVertices ::Buffer T.Float32,
                pyramidColors :: Buffer T.Float32,
                cubeVertices :: Buffer T.Float32,
                cubeColors :: Buffer T.Float32,
                cubeVertexIndices :: Buffer T.Uint16,
                lastTime :: Maybe Number,
                rSphere :: Number,
                rCube :: Number
              }

main :: Eff (console :: CONSOLE, alert :: Alert, clock :: CLOCK) Unit
main =
  runWebGL
    "glcanvas"
    (\s -> alert s)
      \ context -> do
        log "WebGL started"
        withShaders shaders
                    (\s -> alert s)
                      \ bindings -> do
          pyramidVertices <- makeBufferFloat [
                              -- Front face
                               0.0,  1.0,  0.0,
                              -1.0, -1.0,  1.0,
                               1.0, -1.0,  1.0,

                              -- Right face
                               0.0,  1.0,  0.0,
                               1.0, -1.0,  1.0,
                               1.0, -1.0, -1.0,

                              -- Back face
                               0.0,  1.0,  0.0,
                               1.0, -1.0, -1.0,
                              -1.0, -1.0, -1.0,

                              -- Left face
                               0.0,  1.0,  0.0,
                              -1.0, -1.0, -1.0,
                              -1.0, -1.0,  1.0]
          pyramidColors <- makeBufferFloat   [
                              -- Front face
                              1.0, 0.0, 0.0, 1.0,
                              0.0, 1.0, 0.0, 1.0,
                              0.0, 0.0, 1.0, 1.0,

                              -- Right face
                              1.0, 0.0, 0.0, 1.0,
                              0.0, 0.0, 1.0, 1.0,
                              0.0, 1.0, 0.0, 1.0,

                              -- Back face
                              1.0, 0.0, 0.0, 1.0,
                              0.0, 1.0, 0.0, 1.0,
                              0.0, 0.0, 1.0, 1.0,

                              -- Left face
                              1.0, 0.0, 0.0, 1.0,
                              0.0, 0.0, 1.0, 1.0,
                              0.0, 1.0, 0.0, 1.0]

          let a = createOrderedSphere 60 60 
          sphereVerticies <- makeBufferFloat (a)
          sphereColours <- makeBufferFloat (createOrderedSphereColours (length a))
          sphereVertexIndices <- makeBuffer ELEMENT_ARRAY_BUFFER T.asUint16Array (indexCreateOrderedSphere 60 60) 

          tunnelverticies <- makeBufferFloat  [
                              -- frontSquare Face 
                              1.0,  1.0,  1.0,
                              1.0, -1.0,  1.0,
                             -1.0, -1.0,  1.0,
                             -1.0,  1.0,  1.0,
                              0.0,  0.0, -2.0
            ]
          tunnelColours <- makeBufferFloat $ concat [ 
          [1.0,1.0,1.0,1.0],[1.0,0.0,0.0,1.0],[0.0,1.0,0.0,1.0],[0.0,0.0,1.0,1.0], -- frontFace
          [0.0,1.0,0.0,1.0],[0.0,1.0,0.0,1.0],[0.0,0.0,1.0,1.0], -- side1
          [0.0,1.0,0.0,1.0],[0.0,0.0,1.0,1.0],[0.0,0.0,1.0,1.0], -- side2
          [0.0,1.0,0.0,1.0],[1.0,1.0,0.0,1.0],[0.0,0.0,1.0,1.0], -- side3
          [0.0,1.0,0.0,1.0],[1.0,0.0,1.0,1.0],[0.0,0.0,1.0,1.0]] -- side4
          
          tunnelVertexIndices <- makeBuffer ELEMENT_ARRAY_BUFFER T.asUint16Array [
                              0, 1, 2, 0,2,3, -- Front Square 
                              0, 1, 4,        -- side1
                              1, 2, 4,        -- side2
                              2, 3, 4,        -- side3
                              3, 4, 0]        -- side4


          -- cubeVertices <- makeBufferFloat [
          --                   -- Front face
          --                   -1.0, -1.0,  1.0,
          --                    1.0, -1.0,  1.0,
          --                    1.0,  1.0,  1.0,
          --                   -1.0,  1.0,  1.0,

          --                   -- Back face
          --                   -1.0, -1.0, -1.0,
          --                   -1.0,  1.0, -1.0,
          --                    1.0,  1.0, -1.0,
          --                    1.0, -1.0, -1.0,

          --                   -- Top face
          --                   -1.0,  1.0, -1.0,
          --                   -1.0,  1.0,  1.0,
          --                    1.0,  1.0,  1.0,
          --                    1.0,  1.0, -1.0,

          --                   -- Bottom face
          --                   -1.0, -1.0, -1.0,
          --                    1.0, -1.0, -1.0,
          --                    1.0, -1.0,  1.0,
          --                   -1.0, -1.0,  1.0,

          --                   -- Right face
          --                    1.0, -1.0, -1.0,
          --                    1.0,  1.0, -1.0,
          --                    1.0,  1.0,  1.0,
          --                    1.0, -1.0,  1.0,

          --                   -- Left face
          --                   -1.0, -1.0, -1.0,
          --                   -1.0, -1.0,  1.0,
          --                   -1.0,  1.0,  1.0,
          --                   -1.0,  1.0, -1.0]
          -- cubeColors <- makeBufferFloat $ concat $ concatMap (\e -> [e,e,e,e])
          --                     [[1.0, 0.0, 0.0, 1.0], -- Front face
          --                     [1.0, 1.0, 0.0, 1.0], -- Back face
          --                     [0.0, 1.0, 0.0, 1.0], -- Top face
          --                     [1.0, 0.5, 0.5, 1.0], -- Bottom face
          --                     [1.0, 0.0, 1.0, 1.0], -- Right face
          --                     [0.0, 0.0, 1.0, 1.0]]  -- Left face
          -- cubeVertexIndices <- makeBuffer ELEMENT_ARRAY_BUFFER T.asUint16Array [
          --                     0, 1, 2,      0, 2, 3,    -- Front face
          --                     4, 5, 6,      4, 6, 7,    -- Back face
          --                     8, 9, 10,     8, 10, 11,  -- Top face
          --                     12, 13, 14,   12, 14, 15, -- Bottom face
          --                     16, 17, 18,   16, 18, 19, -- Right face
          --                     20, 21, 22,   20, 22, 23]  -- Left face]


          clearColor 0.0 0.0 0.0 1.0
          enable DEPTH_TEST
          let state = {
                        context : context,
                        shaderProgram : bindings.webGLProgram,
                        aVertexPosition : bindings.aVertexPosition,
                        aVertexColor : bindings.aVertexColor,
                        uPMatrix : bindings.uPMatrix,
                        uMVMatrix : bindings.uMVMatrix,
                        -- sphereVerticies : sphereVerticies,
                        -- sphereColours : sphereColours,
                        -- sphereVertexIndices : sphereVertexIndices,
                        pyramidVertices: pyramidVertices,
                        pyramidColors: pyramidColors,

                        cubeVertices : sphereVerticies,
                        cubeColors : sphereColours,
                        cubeVertexIndices : sphereVertexIndices,

                        lastTime : Nothing,
                        rSphere : 0.0,
                        rCube : 0.0
                      }
          tick state

tick :: forall eff. State ->  EffWebGL (console :: CONSOLE, clock :: CLOCK |eff) Unit
tick state = do
--  log ("tick: " ++ show state.lastTime)
  drawScene state
  state' <- animate state
  requestAnimationFrame (tick state')

animate ::  forall eff. State -> EffWebGL (clock :: CLOCK |eff) State
animate state = do
  timeNow <- milliseconds
  case state.lastTime of
    Nothing -> pure state {lastTime = Just timeNow}
    Just lastt ->
      let elapsed = timeNow - lastt
      in pure state {lastTime = Just timeNow,
                       rSphere = state.rSphere + (90.0 * elapsed) / 1000.0,
                       rCube = state.rCube + (75.0 * elapsed) / 1000.0}

drawScene :: forall eff. State -> EffWebGL (clock :: CLOCK |eff) Unit
drawScene s = do
      canvasWidth <- getCanvasWidth s.context
      canvasHeight <- getCanvasHeight s.context
      viewport 0 0 canvasWidth canvasHeight
      clear [COLOR_BUFFER_BIT, DEPTH_BUFFER_BIT]

-- The pyramid
      let pMatrix = M.makePerspective 45.0 (toNumber canvasWidth / toNumber canvasHeight) 0.1 100.0
      setUniformFloats s.uPMatrix (M.toArray pMatrix)
      let mvMatrix = M.rotate (degToRad s.rSphere) (V3.vec3' [1.0, 0.0, 0.0])
                        $ M.translate  (V3.vec3 (-1.5) 0.0 (-8.0))
                          $ M.identity

      setUniformFloats s.uMVMatrix (M.toArray mvMatrix)
      bindBufAndSetVertexAttr s.pyramidColors s.aVertexColor
      drawArr TRIANGLES s.pyramidVertices s.aVertexPosition      
      -- bindBufAndSetVertexAttr s.sphereColours s.aVertexColor
      -- bindBufAndSetVertexAttr s.sphereVerticies s.aVertexPosition
      -- bindBuf s.sphereVertexIndices
      -- drawElements POINTS s.sphereVertexIndices.bufferSize
      -- drawArr TRIANGLES s.sphereVerticies s.aVertexPosition

-- The cube
      let mvMatrix' = M.rotate (degToRad s.rCube) (V3.vec3' [1.0, 1.0, 1.0])
                        $ M.translate  (V3.vec3 (1.5) 0.0 (-8.0))
                          $ M.identity
      setUniformFloats s.uMVMatrix (M.toArray mvMatrix')

      bindBufAndSetVertexAttr s.cubeColors s.aVertexColor
      bindBufAndSetVertexAttr s.cubeVertices s.aVertexPosition
      bindBuf s.cubeVertexIndices
      drawElements TRIANGLES s.cubeVertexIndices.bufferSize


-- | Convert from radians to degrees.
radToDeg :: Number -> Number
radToDeg x = x/pi*180.0

-- | Convert from degrees to radians.
degToRad :: Number -> Number
degToRad x = x/180.0*pi



-- CREATE AN ORDERED SPHERE
-- CREATE AN ORDERED SPHERE
-- CREATE AN ORDERED SPHERE

createOrderedSphere :: Int -> Int -> (Array Number)
createOrderedSphere lat long = concat (concat (latfunc lat long 1 0))

latfunc :: Int -> Int -> Int -> Int -> Array (Array (Array Number))
latfunc latB longB r latN 
    | latN <= latB = (longfunc latB longB r latN 0 ) : (latfunc latB longB r (latN + 1 ))
    | otherwise = []

--          latB->longB->  r  -> latN->longR
longfunc :: Int -> Int -> Int -> Int -> Int -> Array (Array Number)
longfunc latB longB r latN longN
    | longN <= longB = [x,y,z] : (longfunc latB longB r latN (longN + 1)) 
    where x = (toNumber (r)) * cos(phi longB longN) * sin(theta latB latN)
          y = (toNumber (r)) * cos(theta latB latN) 
          z = (toNumber (r)) * sin(phi longB longN) * sin(theta latB latN)
    | otherwise = []

theta :: Int -> Int -> Number 
theta latB latN = (toNumber latN) * pi / (toNumber latB)

phi :: Int -> Int -> Number 
phi longB longN = (toNumber longN) * 2.0 * pi / (toNumber longB)

createOrderedSphereColours :: Int -> Array Number
createOrderedSphereColours a = concatMap (\n -> map toNumber [1,1,1,1] ) (1..a)

-- Create Index data of sphere 
-- Create Index data of sphere 
-- Create Index data of sphere 

indexCreateOrderedSphere :: Int -> Int -> (Array Int)
indexCreateOrderedSphere lat long = concat (concat (indexlatfunc lat long 0))

indexlatfunc :: Int -> Int -> Int -> Array (Array (Array Int))
indexlatfunc latB longB latN 
    | latN < latB = (indexlongfunc latB longB latN 0 ) : (indexlatfunc latB longB (latN + 1 ))
    | otherwise = []

indexlongfunc :: Int -> Int -> Int -> Int -> Array (Array Int)
indexlongfunc latB longB latN longN
    | longN < longB = [first,second,first+1,second,second+1,first+1] : (indexlongfunc latB longB latN (longN + 1)) 
    -- | longN < longB = [first+1,second+1,second,first+1,second,first] : (indexlongfunc latB longB latN (longN + 1)) 
      where second = first + longB + 1
            first = (latN * (longB + 1)) + longN
    | otherwise = []


-- Purscript output
 -- [0.0,1.0,0.0,0.0,1.0,0.0,0.0,1.0,0.0,0.0,1.0,0.0,0.8660254037844386,0.5000000000000001,0.0,-0.43301270189221913,0.5000000000000001,0.75,-0.4330127018922197,0.5000000000000001,-0.7499999999999997,0.8660254037844386,0.5000000000000001,-2.1211504774498136e-16,0.8660254037844387,-0.4999999999999998,0.0,-0.4330127018922192,-0.4999999999999998,0.7500000000000001,-0.43301270189221974,-0.4999999999999998,-0.7499999999999998,0.8660254037844387,-0.4999999999999998,-2.1211504774498138e-16,1.2246467991473532e-16,-1.0,0.0,-6.123233995736764e-17,-1.0,1.0605752387249069e-16,-6.123233995736771e-17,-1.0,-1.0605752387249065e-16,1.2246467991473532e-16,-1.0,-2.999519565323715e-32]

-- Javascript output
-- [0.0,1.0,0.0,0.0,1.0,0.0,0.0,1.0,0.0,0.0,1.0,0.0,0.8660254037844386,0.5000000000000001,0.0,-0.43301270189221913,0.5000000000000001,0.75,-0.4330127018922197,0.5000000000000001,-0.7499999999999997,0.8660254037844386,0.5000000000000001,-2.1211504774498136e-16,0.8660254037844387,-0.4999999999999998,0.0,-0.4330127018922192,-0.4999999999999998,0.7500000000000001,-0.43301270189221974,-0.4999999999999998,-0.7499999999999998,0.8660254037844387,-0.4999999999999998,-2.1211504774498138e-16,1.2246467991473532e-16,-1.0,0.0,-6.123233995736764e-17,-1.0,1.0605752387249069e-16,-6.123233995736771e-17,-1.0,-1.0605752387249065e-16,1.2246467991473532e-16,-1.0,-2.999519565323715e-32]


-- PS data [0,4,1,4,5,1,1,5,2,5,6,2,2,6,3,6,7,3,4,8,5,8,9,5,5,9,6,9,10,6,6,10,7,10,11,7,8,12,9,12,13,9,9,13,10,13,14,10,10,14,11,14,15,11]
--         [0,4,1,4,5,1,1,5,2,5,6,2,2,6,3,6,7,3,4,8,5,8,9,5,5,9,6,9,10,6,6,10,7,10,11,7,8,12,9,12,13,9,9,13,10,13,14,10,10,14,11,14,15,11]