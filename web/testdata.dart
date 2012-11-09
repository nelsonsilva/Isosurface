part of isosurface;

_memoize(f) {
  var cached = null;
  return () {
    if(cached === null) { 
      cached = f();
    }
    return cached;
  };
}

_makeVolume(dims, f) {
  return _memoize(() {
    var res = new List(3);
    for(var i=0; i<3; ++i) {
      res[i] = 2 + ((dims[i][1] - dims[i][0]) / dims[i][2]).ceil().toInt();
    }
    var volume = new Float32Array(res[0] * res[1] * res[2])
      , n = 0;
    for(var k=0, z=dims[2][0]-dims[2][2]; k<res[2]; ++k, z+=dims[2][2])
    for(var j=0, y=dims[1][0]-dims[1][2]; j<res[1]; ++j, y+=dims[1][2])
    for(var i=0, x=dims[0][0]-dims[0][2]; i<res[0]; ++i, x+=dims[0][2], ++n) {
      volume[n] = f(x,y,z);
    }
    return {"data": volume, "dims":res};
  });
}

createTestData() {
  var result = {};
  
  result['Sphere'] = _makeVolume(
    [[-1.0, 1.0, 0.25],
     [-1.0, 1.0, 0.25],
     [-1.0, 1.0, 0.25]],
    (x,y,z) => x*x + y*y + z*z - 1.0
  );
  
  result['Torus'] = _makeVolume(
    [[-2.0, 2.0, 0.2],
     [-2.0, 2.0, 0.2],
     [-1.0, 1.0, 0.2]],
    (x,y,z) => Math.pow(1.0 - Math.sqrt(x*x + y*y), 2) + z*z - 0.25
  );

  result['Big Sphere'] = _makeVolume(
    [[-1.0, 1.0, 0.05],
     [-1.0, 1.0, 0.05],
     [-1.0, 1.0, 0.05]],
    (x,y,z) => x*x + y*y + z*z - 1.0
  );
  
  result['Hyperelliptic'] = _makeVolume(
    [[-1.0, 1.0, 0.05],
     [-1.0, 1.0, 0.05],
     [-1.0, 1.0, 0.05]],
    (x,y,z) => Math.pow( Math.pow(x, 6) + Math.pow(y, 6) + Math.pow(z, 6), 1.0/6.0 ) - 1.0 
  );
  
  result['Nodal Cubic'] = _makeVolume(
    [[-2.0, 2.0, 0.05],
     [-2.0, 2.0, 0.05],
     [-2.0, 2.0, 0.05]],
    (x,y,z) => x*y + y*z + z*x + x*y*z
  );
  
  result["Goursat's Surface"] = _makeVolume(
    [[-2.0, 2.0, 0.05],
     [-2.0, 2.0, 0.05],
     [-2.0, 2.0, 0.05]],
    (x,y,z) => Math.pow(x,4) + Math.pow(y,4) + Math.pow(z,4) - 1.5 * (x*x  + y*y + z*z) + 1
  );
  
  result["Heart"] = _makeVolume(
    [[-2.0, 2.0, 0.05],
     [-2.0, 2.0, 0.05],
     [-2.0, 2.0, 0.05]],
    (x,y,z) {
      y *= 1.5;
      z *= 1.5;
      return Math.pow(2*x*x+y*y+2*z*z-1, 3) - 0.1 * z*z*y*y*y - y*y*y*x*x;
    }
  );
  
  result["Nordstrand's Weird Surface"] = _makeVolume(
    [[-0.8, 0.8, 0.01],
     [-0.8, 0.8, 0.01],
     [-0.8, 0.8, 0.01]],
    (x,y,z) {
      return 25 * (Math.pow(x,3)*(y+z) + Math.pow(y,3)*(x+z) + Math.pow(z,3)*(x+y)) +
        50 * (x*x*y*y + x*x*z*z + y*y*z*z) -
        125 * (x*x*y*z + y*y*x*z+z*z*x*y) +
        60*x*y*z -
        4*(x*y+x*z+y*z);
    }
  );
  
  result['Sine Waves'] = _makeVolume(
    [[-Math.PI*2, Math.PI*2, Math.PI/8],
     [-Math.PI*2, Math.PI*2, Math.PI/8],
     [-Math.PI*2, Math.PI*2, Math.PI/8]],
    (x,y,z) => Math.sin(x) + Math.sin(y) + Math.sin(z)
  );
  
  
  result['Empty'] = () => { "data": new Float32Array(32*32*32), "dims":[32,32,32] };
  
  return result;
}