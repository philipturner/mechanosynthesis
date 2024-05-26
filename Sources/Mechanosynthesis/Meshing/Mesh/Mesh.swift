//
//  Mesh.swift
//
//
//  Created by Philip Turner on 5/26/24.
//

public struct MeshDescriptor {
  // Required. The set of octrees to generate the topology from.
  public var octrees: [Octree] = []
  
  // Optional. The shift of each octree with respect to the origin.
  //
  // To initialize the ansatz easily and accurately, the octree should be
  // origin-centered and with minimal size exponent. This setting
  // allows different origin-centered meshes to be created for different
  // atoms, then fused after shifting to the actual position.
  //
  // Each shift must be a multiple of the coarse voxel spacing.
  public var positions: [SIMD3<Int32>]?
  
  // Required. The power-2 size of coarse voxels, in Bohr.
  public var sizeExponent: Int?
  
  public init() {
    
  }
}

public struct Mesh {
  // A uniform grid of coarse voxels.
  public var coarseVoxels: Grid<CoarseVoxel>
  
  // The separation between coarse voxels, in Bohr.
  public var spacing: Int
  
  public init(descriptor: MeshDescriptor) {
    // Check the correctness of the size exponent.
    guard let sizeExponent = descriptor.sizeExponent else {
      fatalError("Descriptor was incomplete.")
    }
    guard sizeExponent > 0 else {
      fatalError("Coarse voxel spacing must be at least 2 Bohr.")
    }
    
    // Set the coarse voxel spacing.
    spacing = 1 << sizeExponent
    Self.checkOctreeSizes(
      octrees: descriptor.octrees,
      spacing: spacing)
    
    // Detach the nodes from the octrees.
    let nodes = Self.detachOctreeNodes(
      octrees: descriptor.octrees,
      positions: descriptor.positions,
      spacing: spacing)
    
    // Create an empty grid with the smallest possible bounding box.
    let coarseBoundingBox = Self.createCoarseBoundingBox(
      nodes: nodes,
      spacing: spacing)
    coarseVoxels = Self.createCoarseGrid(
      minimum: coarseBoundingBox.minimum,
      maximum: coarseBoundingBox.maximum)
    
    // Data Transformations
    // sizeExponent -> spacing
    // descriptor -> coarseVoxels
    // for each octree
    //   octree, coarseVoxelGrid bounding box -> map
    // prefix sum the slot count for each octree
    // detach the nodes from the octrees, place into an array for each voxel
    print(nodes.count)
    mapNodesToCoarseVoxels(nodes)
  }
}
