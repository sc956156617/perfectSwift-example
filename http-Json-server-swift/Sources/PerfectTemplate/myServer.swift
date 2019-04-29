
//
//  myServer.swift
//  COpenSSL
//
//  Created by chao shen on 2019/4/29.
//


import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

open class MyServer{
    
    fileprivate var server : HTTPServer
    
    internal init(root : String , port : UInt16){
        // 构造httpServer对象
        server = HTTPServer.init()
        // 构造路由对象
        var routes = Routes.init()
        // 配置路由 （URL，回调函数）
        configure(routes: &routes)
        // 将路由添加进服务
        server.addRoutes(routes)
        // 设置根目录和端口
        server.documentRoot = root
        server.serverPort = port
    }
    
    // 配置路由的方法
    fileprivate func configure(routes : inout Routes){
        
        // 添加接口， 路径为/,请求方法为GET，回调函数为闭包
        routes.add(method: .get, uri: "/") { (request, response) in
            // 取得URL中的参数
            //            let param = request.params()
            
            //返回数据头
            response.setHeader(.contentType, value: "text/html")
            //返回数据体
            response.appendBody(string: "Hello world")
            //返回
            response.completed()
        }
        
        // get请求 在闭包里对这个请求做处理 返回一个json
        routes.add(method: .get, uri: "/getDatas") { (request, response) in
            response.setHeader(.contentType, value: "application/json; charset=utf-8")
            // 获取参数
            guard let content = request.param(name: "content") else{
                let jsonString = self.baseResponseBodyJSONData(status: -1, message: "失败", data: "缺少参数")
                response.setBody(string: jsonString)
                response.completed()
                return
            }
            
            let dic = ["content" : content]
            let jsonString = self.baseResponseBodyJSONData(status: 200, message: "请求成功", data: dic)
            response.setBody(string: jsonString)
            response.completed()
        }
    }
    
    
    // 生成字符串文字
    private func baseResponseBodyJSONData(status : Int, message : String, data : Any!) -> String{
        
        var result = Dictionary<String, Any>()
        result.updateValue(status, forKey: "status")
        result.updateValue(message, forKey: "message")
        if (data != nil){
            result.updateValue(data, forKey: "data")
        }else{
            result.updateValue("", forKey: "data")
        }
        
        guard let jsonString = try? result.jsonEncodedString() else{
            return ""
        }
        return jsonString
    }
    
    
    // 启动服务
    open func start(){
        do {
            try self.server.start()
        } catch PerfectError.networkError(let err, let msg) {
            print("Network error thrown: \(err) \(msg)")
        } catch{
            print("Network unknow error")
            
        }
    }
}
