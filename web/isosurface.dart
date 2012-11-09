library isosurface;

import 'dart:html';
import 'dart:math' as Math;
import 'package:three/three.dart' as THREE;
import 'package:three/extras/controls/trackball.dart' as THREE;
import 'package:stats/stats.dart';

part 'marching_cubes.dart';
part 'testdata.dart';

var stats, scene, renderer, composer;
var camera, cameraControls;
var geometry, surfacemesh, wiremesh;
var testdata;

_input(id) => query("#$id") as InputElement;

updateMesh() {

  scene.remove( surfacemesh );
  scene.remove( wiremesh );
  
  //Create surface mesh
  geometry  = new THREE.Geometry();
  
  var mesher = new MarchingCubes(), 
      field  = testdata[ (query("#datasource") as SelectElement).value ]();
  
  var clock = new Stopwatch()..start();
  var result = mesher.call( field["data"], field["dims"] );
  clock.stop();
  
  //Update statistics
  _input("resolution").value = Strings.join(field["dims"].map((n) => n.toString()), 'x');
  _input("vertcount").value = result.vertices.length.toString();
  _input("facecount").value = result.faces.length.toString();
  _input("meshtime").value = (clock.elapsedMilliseconds / 1000).toString();
  
  geometry.vertices.length = 0;
  geometry.faces.length = 0;
  
  result.vertices.forEach((v) {
    geometry.vertices.add(new THREE.Vector3(v[0], v[1], v[2]));
  });
  
  result.faces.forEach((f) {
    if(f.length == 3) {
      geometry.faces.add(new THREE.Face3(f[0], f[1], f[2]));
    } else if(f.length == 4) {
      geometry.faces.push(new THREE.Face4(f[0], f[1], f[2], f[3]));
    } else {
      //Polygon needs to be subdivided
    }
  });
  
  geometry.computeFaceNormals();
  
  var webglGeometry = new THREE.WebGLGeometry.from(geometry);
  webglGeometry.verticesNeedUpdate = true;
  webglGeometry.elementsNeedUpdate = true;
  webglGeometry.normalsNeedUpdate = true;
  
  geometry.computeBoundingBox();
  geometry.computeBoundingSphere();
  
  var material  = new THREE.MeshNormalMaterial();
  surfacemesh = new THREE.Mesh( geometry, material );
  surfacemesh.doubleSided = true;
  var wirematerial = new THREE.MeshBasicMaterial(
    color : 0xffffff, wireframe : true
  );
  wiremesh = new THREE.Mesh(geometry, wirematerial);
  wiremesh.doubleSided = true;
  scene.add( surfacemesh );
  scene.add( wiremesh );      

  var bb = geometry.boundingBox;
  wiremesh.position.x = surfacemesh.position.x = -(bb.max.x + bb.min.x) / 2.0;
  wiremesh.position.y = surfacemesh.position.y = -(bb.max.y + bb.min.y) / 2.0;
  wiremesh.position.z = surfacemesh.position.z = -(bb.max.z + bb.min.z) / 2.0;
}

// init the scene
init(){
  renderer = new THREE.WebGLRenderer();
  renderer.setClearColorHex( 0xBBBBBB, 1 );
  
  renderer.setSize( window.innerWidth, window.innerHeight );
  query('#container').elements.add(renderer.domElement);

  // add Stats.js - https://github.com/mrdoob/stats.js
  stats = new Stats();
  stats.container.style.position = 'absolute';
  stats.container.style.bottom = '0px';
  document.body.elements.add( stats.container );

  // create a scene
  scene = new THREE.Scene();

  // put a camera in the scene
  camera  = new THREE.PerspectiveCamera(35, window.innerWidth / window.innerHeight, 1, 10000 );
  camera.position.setValues(0, 0, 40);
  scene.add(camera);

  // create a camera contol
  cameraControls  = new THREE.TrackballControls( camera, query('#container') );

  var rnd = new Math.Random();
  
  // here you add your objects
  // - you will most likely replace this part by your own
  var alight = new THREE.AmbientLight( rnd.nextInt(0xffffff) );
  scene.add( alight );
  
  var dlight = new THREE.DirectionalLight( rnd.nextInt(0xffffff) );
  dlight.position.setValues( rnd.nextDouble(), rnd.nextDouble(), rnd.nextDouble() ).normalize();
  scene.add( dlight );
  
  //Initialize dom elements
  testdata = createTestData();
  SelectElement ds = query("#datasource");
  testdata.forEach((id, v) => ds.elements.add(new Element.html('<option value="$id">$id</option>')));
  ds.on.change.add((_) => updateMesh());
 
  _input("showfacets").checked = true;
  _input("showedges").checked  = true;
  
  //Update mesh
  updateMesh();
}

// render the scene
render() {
  // variable which is increase by Math.PI every seconds - usefull for animation
  var PIseconds = new Date.now().millisecondsSinceEpoch * Math.PI;

  // update camera controls
  cameraControls.update();

  surfacemesh.visible = _input("showfacets").checked;
  wiremesh.visible = _input("showedges").checked;

  // actually render the scene
  renderer.render( scene, camera );
}

// animation loop
animate(t) {

  window.requestAnimationFrame( animate );

  // do the render
  render();

  // update stats
  //stats.update();
}



void main() {
  init();
  animate(0);
}

