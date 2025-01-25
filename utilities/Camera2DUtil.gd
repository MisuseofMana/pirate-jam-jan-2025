class_name Camera2DUtil

static func get_current_camera_2d_rect(node_in_tree: Node) -> Rect2:
    var camera := node_in_tree.get_viewport().get_camera_2d()
    var camera_inverse := camera.get_global_transform().scaled(camera.zoom).affine_inverse()
    var viewport_rect := node_in_tree.get_viewport().get_visible_rect()
    viewport_rect.position -= viewport_rect.size / 2.0
    var result := viewport_rect * camera_inverse
    return result