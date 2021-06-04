//
//  Utiltiy.swift
//  Mesh
//
//  Created by Indrajit Chavda on 04/06/21.
//

import ARKit
import SceneKit

extension ARMeshGeometry {
    func classificationOf(faceWithIndex index: Int) -> ARMeshClassification {
        guard let classification = classification else { return .none }
        assert(classification.format == MTLVertexFormat.uchar, "Expected one unsigned char (one byte) per classification")
        let classificationPointer = classification.buffer.contents().advanced(by: classification.offset + (classification.stride * index))
        let classificationValue = Int(classificationPointer.assumingMemoryBound(to: CUnsignedChar.self).pointee)
        return ARMeshClassification(rawValue: classificationValue) ?? .none
    }
}

extension  SCNGeometry {
    convenience init(arGeometry: ARMeshGeometry) {
        let verticesSource = SCNGeometrySource(arGeometry.vertices, semantic: .vertex)
        let normalsSource = SCNGeometrySource(arGeometry.normals, semantic: .normal)
        let faces = SCNGeometryElement(arGeometry.faces)
        self.init(sources: [verticesSource, normalsSource], elements: [faces])
    }
}
extension  SCNGeometrySource {
    convenience init(_ source: ARGeometrySource, semantic: Semantic) {
        self.init(buffer: source.buffer, vertexFormat: source.format, semantic: semantic, vertexCount: source.count, dataOffset: source.offset, dataStride: source.stride)
    }
}
extension  SCNGeometryElement {
    convenience init(_ source: ARGeometryElement) {
        let pointer = source.buffer.contents()
        let byteCount = source.count * source.indexCountPerPrimitive * source.bytesPerIndex
        let data = Data(bytesNoCopy: pointer, count: byteCount, deallocator: .none)
        self.init(data: data, primitiveType: .of(source.primitiveType), primitiveCount: source.count, bytesPerIndex: source.bytesPerIndex)
    }
}
extension  SCNGeometryPrimitiveType {
    static  func  of(_ type: ARGeometryPrimitiveType) -> SCNGeometryPrimitiveType {
        switch type {
            case .line:
                return .line
            case .triangle:
                return .triangles
            @unknown default:
                return .line
        }
    }
}

class Colorizer {
    
    struct storedColors {
        var id: UUID
        var color: UIColor
    }
    var savedColors = [storedColors]()
    
    init() {
        
    }
    
    func assignColor(to: UUID, classification: ARMeshClassification) -> UIColor {
        return savedColors.first(where: { $0.id == to })?.color ?? saveColor(uuid: to, classification: classification)
    }
    
    func saveColor(uuid: UUID, classification: ARMeshClassification) -> UIColor {
        let newColor = classification.color.withAlphaComponent(0.7)
        let stored = storedColors(id: uuid, color: newColor)
        savedColors.append(stored)
        return newColor
    }
}

extension ARMeshClassification {
    var description: String {
        switch self {
            case .ceiling: return "Ceiling"
            case .door: return "Door"
            case .floor: return "Floor"
            case .seat: return "Seat"
            case .table: return "Table"
            case .wall: return "Wall"
            case .window: return "Window"
            case .none: return "None"
            @unknown default: return "Unknown"
        }
    }
    
    var color: UIColor {
        switch self {
            case .ceiling: return .cyan
            case .door: return .brown
            case .floor: return .red
            case .seat: return .purple
            case .table: return .yellow
            case .wall: return .green
            case .window: return .blue
            case .none: return .lightGray
            @unknown default: return .gray
        }
    }
}
