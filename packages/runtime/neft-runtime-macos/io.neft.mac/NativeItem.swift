import Cocoa

class NativeItem: Item {
    class NativeUIView: NSView {}

    static var types: [String: () -> NativeItem] = [:]
    class var name: String { return "Unknown" }

    override class func register() {
        onAction(.createNativeItem) {
            (reader: Reader) in
            let ctorName = reader.getString()
            let ctor = types[ctorName]
            if ctor == nil {
                print("Native item '\(ctorName)' type not found")
                save(item: NativeItem())
            } else {
                save(item: ctor!())
            }
        }

        onAction(.onNativeItemPointerPress) {
            (item: NativeItem, reader: Reader) in
            item.onPointerPress(reader.getFloat(), reader.getFloat())
        }

        onAction(.onNativeItemPointerMove) {
            (item: NativeItem, reader: Reader) in
            item.onPointerMove(reader.getFloat(), reader.getFloat())
        }

        onAction(.onNativeItemPointerRelease) {
            (item: NativeItem, reader: Reader) in
            item.onPointerRelease(reader.getFloat(), reader.getFloat())
        }
    }

    private static func on<T: NativeItem>(
        _ type: String,
        _ name: String,
        _ handler: @escaping (T, [Any?]) -> Void
        ) {
        let funcName = "renderer\(type)\(self.name.uppercaseFirst)\(name.uppercaseFirst)"
        App.getApp().client.addCustomFunction(funcName) {
            (inputArgs: [Any?]) in
            var args = inputArgs
            let index = (args[0] as! Number).int()
            let item = App.getApp().renderer.items[index] as! T
            args.removeFirst()
            handler(item, args)
        }
    }

    internal static func onSet<T: NativeItem>(
        _ propertyName: String,
        _ handler: @escaping (T, [Any?]) -> Void
        ) {
        on("Set", propertyName, handler)
    }

    internal static func onSet<T: NativeItem>(
        _ propertyName: String,
        _ handler: @escaping (T, Bool) -> Void
        ) {
        onSet(propertyName) {
            (item: T, args: [Any?]) in
            handler(item, args[0] as! Bool)
        }
    }

    internal static func onSet<T: NativeItem>(
        _ propertyName: String,
        _ handler: @escaping (T, CGFloat) -> Void
        ) {
        onSet(propertyName) {
            (item: T, args: [Any?]) in
            handler(item, (args[0] as! Number).float())
        }
    }

    internal static func onSet<T: NativeItem>(
        _ propertyName: String,
        _ handler: @escaping (T, Int) -> Void
        ) {
        onSet(propertyName) {
            (item: T, args: [Any?]) in
            handler(item, (args[0] as! Number).int())
        }
    }

    internal static func onSet<T: NativeItem>(
        _ propertyName: String,
        _ handler: @escaping (T, NSColor?) -> Void
        ) {
        onSet(propertyName) {
            (item: T, val: Int?) in
            handler(item, val != nil ? Color.hexColorToNSColor(val!) : nil)
        }
    }

    internal static func onSet<T: NativeItem>(
        _ propertyName: String,
        _ handler: @escaping (T, Item?) -> Void
        ) {
        onSet(propertyName) {
            (item: T, val: Int?) in
            handler(item, val != nil && val! >= 0 ? renderer.items[val!] : nil)
        }
    }

    internal static func onSet<T: NativeItem>(
        _ propertyName: String,
        _ handler: @escaping (T, String) -> Void
        ) {
        onSet(propertyName) {
            (item: T, args: [Any?]) in
            handler(item, args[0] as! String)
        }
    }

    internal static func onCall<T: NativeItem>(
        _ funcName: String,
        _ handler: @escaping (T, [Any?]) -> Void
        ) {
        on("Call", funcName, handler)
    }

    internal static func onCreate<T: NativeItem>(
        handler: @escaping () -> T
        ) {
        NativeItem.types[self.name] = handler
    }

    var autoWidth = true
    var autoHeight = true
    override var keysFocus: Bool {
        didSet {
            if keysFocus {
                itemView.becomeFirstResponder()
            } else {
                itemView.resignFirstResponder()
            }
        }
    }

    override var width: CGFloat {
        didSet {
            autoWidth = width == 0
            updateSize()
        }
    }

    override var height: CGFloat {
        didSet {
            autoHeight = height == 0
            updateSize()
        }
    }

    let itemView: NSView

    init(itemView: NSView = NSView()) {
        self.itemView = itemView
        super.init()
        view.addSubview(itemView)
    }

    override func didSave() {
        super.didSave()
        updateSize()
    }

    internal func updateSize() {
        let width = autoWidth ? itemView.frame.width : self.width
        let height = autoHeight ? itemView.frame.height : self.height
        itemView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        pushWidth(width)
        pushHeight(height)
    }

    private func pushWidth(_ val: CGFloat) {
        if autoWidth && width != val {
            self.width = val
            pushAction(.nativeItemWidth, val)
        }
    }

    private func pushHeight(_ val: CGFloat) {
        if autoHeight && height != val {
            self.height = val
            pushAction(.nativeItemHeight, val)
        }
    }

    internal func onPointerPress(_ x: CGFloat, _ y: CGFloat) {
    }

    internal func onPointerRelease(_ x: CGFloat, _ y: CGFloat) {
    }

    internal func onPointerMove(_ x: CGFloat, _ y: CGFloat) {
    }

    internal func pushEvent(event: String, args: [Any?]?) {
        let eventName = "rendererOn\(type(of: self).name.uppercaseFirst)\(event.uppercaseFirst)"
        var clientArgs: [Any?] = [id]
        if args != nil {
            clientArgs.append(contentsOf: args!)
        }
        App.getApp().client.pushEvent(eventName, args: clientArgs)
    }

}
