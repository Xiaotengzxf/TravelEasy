//
//  URLCollection.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/8/13.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class URLCollection: NSObject {
    
    let url = "http://www.chuchaiyi.cn"
    // 登录
    var login : String {
        return "\(url)/api/Account/Login"
    }
    // 退出登录
    var loginOut : String {
        return "\(url)/api/Account/Logout"
    }
    // 修改密码
    var ChangePassword : String {
        return "\(url)/api/Account/ChangePassword"
    }
    // 刷新当前登录人的相关信息
    var refreshLoginInfo : String {
        return "\(url)/api/Account/RefreshLoginInfo"
    }
    // 提交出差审批单
    var createAskApproval : String {
        return "\(url)/api/Approval/CreateAskApproval"
    }
    // 查询指定员工的出差审批单列表，用来在预订时选择审批单
    var getApprovals : String {
        return "\(url)/api/Approval/GetApprovals"
    }
    // 我的申请单列表数据
    var getMyApprovals : String {
        return "\(url)/api/Approval/GetMyApprovals"
    }
    // 待我审批列表数据
    var getApprovalsToAuditForMe : String {
        return "\(url)/api/Approval/GetApprovalsToAuditForMe"
    }
    // 我的历史审批列表数据
    var getApprovalsAuditedByMe : String {
        return "\(url)/api/Approval/GetApprovalsAuditedByMe"
    }
    // 查询审批单详情
    var getApprovalDetail : String {
        return "\(url)/api/Approval/GetApprovalDetail"
    }
    // 撤消出差申请单
    var cancelApproval : String {
        return "\(url)/api/Approval/CancelApproval"
    }
    // 审批通过申请单
    var auditPassApproval : String {
        return "\(url)/api/Approval/AuditPassApproval"
    }
    // 审批拒绝申请单
    var auditRejectApproval : String {
        return "\(url)/api/Approval/AuditRejectApproval"
    }
    // 待我授权列表数据
    var getAuthorizeSheetsToAuditForMe : String {
        return "\(url)/api/Approval/GetAuthorizeSheetsToAuditForMe"
    }
    // 我的历史授权列表数据
    var getAuthorizeSheetsAuditedByMe : String {
        return "\(url)/api/Approval/GetAuthorizeSheetsAuditedByMe"
    }
    // 查询授权单详情
    var getAuthorizeDetail : String {
        return "\(url)/api/Approval/GetAuthorizeDetail"
    }
    // 授权通过超标授权单
    var auditPassAuthorize : String {
        return "\(url)/api/Approval/AuditPassAuthorize"
    }
    // 授权拒绝超标授权单
    var auditRejectAuthorize : String {
        return "\(url)/api/Approval/AuditRejectAuthorize"
    }
    // 获取我的常用姓名信息
    var getMyStoredUsers : String {
        return "\(url)/api/Common/GetMyStoredUsers"
    }
    // 查询符合条件的员工信息
    var getEmployees : String {
        return "\(url)/api/Common/GetEmployees"
    }
    var getEmployee : String {
        return "\(url)/api/Common/GetEmployee"
    }
    // 获取证件类型
    var getCertTypes : String {
        return "\(url)/api/Common/GetCertTypes"
    }
    // 获取项目信息
    var getProjects : String {
        return "\(url)/api/Common/GetProjects"
    }
    // 获取公司部门信息
    var getDepartments : String {
        return "\(url)/api/Common/GetDepartments"
    }
    // 国内机票城市(或机场)数据查询
    var getFlightLocations : String {
        return "\(url)/api/Flight/GetFlightLocations"
    }
    // 国内机票航班及价格查询
    var getFlights : String {
        return "\(url)/api/Flight/GetFlights"
    }
    // 机票列表页面点击预订按钮时调用此接口进行差旅政策验证
    var bookingValidate : String {
        return "\(url)/api/Flight/BookingValidate"
    }
    // 查询航班的退改签政策
    var getFlightPolicy : String {
        return "\(url)/api/Flight/GetFlightPolicy"
    }
    // 查询机型信息
    var getPlanType : String {
        return "\(url)/api/Flight/GetPlanType"
    }
    // 查询经停信息
    var getFlightStops : String {
        return "\(url)/api/Flight/GetFlightStops"
    }
    // 提交订单
    var placeAskOrder : String {
        return "\(url)/api/Flight/PlaceAskOrder"
    }
    // 查询我的订单列表信息
    var getMyFlightOrders : String {
        return "\(url)/api/Flight/GetMyFlightOrders"
    }
    // 查询订单详情
    var getOrderDetail : String {
        return "\(url)/api/Flight/GetOrderDetail"
    }
    // 预订成功以后调用此接口对预订申请单确认出票
    var askOrderConfirmByCorpCredit : String {
        return "\(url)/api/Flight/AskOrderConfirmByCorpCredit"
    }
    // 订单确认出票
    var orderConfirmByCorpCredit : String {
        return "\(url)/api/Flight/OrderConfirmByCorpCredit"
    }
    // 订单取消申请
    var cancelApply : String {
        return "\(url)/api/Flight/CancelApply"
    }
    // 订单退票申请
    var returnApply : String {
        return "\(url)/api/Flight/ReturnApply"
    }
    // 订单改签申请
    var changeApply : String {
        return "\(url)/api/Flight/ChangeApply"
    }
    // 代办值机申请
    var netCheckInApply : String {
        return "\(url)/api/Flight/NetCheckInApply"
    }
    
    //获取员工差旅标准描述
    var getEmployeePolicyInfo : String {
        return "\(url)/api/Common/GetEmployeePolicyInfo"
    }
    
    // 获取验证码
    var sendSmsValidateCode : String {
        return "\(url)/api/Account/SendSmsValidateCode"
    }
    
    // 重置新密码
    var resetPassword : String {
        return "\(url)/api/Account/ResetPassword"
    }
    
    var getApprovalAndAuthorizeCount : String {
        return "\(url)/api/Approval/GetApprovalAndAuthorizeCount"
    }
    
    func postRequest(_ urlString : String , params : [String : Any]? , headers : [String : String]? , callback : @escaping (JSON? , Error?)->()) {
        Alamofire.request(urlString, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                print(value)
                callback( JSON(value) , nil)
            case .failure(let error):
                callback(nil , error)
            }
        }
    }
    
    func postRequest(_ urlString : String , params : [String : Any]? , encoding : ParameterEncoding , headers : [String : String]? , callback : @escaping (JSON? , Error?)->()) {
        Alamofire.request(urlString, method: .post, parameters: params, encoding: encoding, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                print(value)
                callback( JSON(value) , nil)
            case .failure(let error):
                callback(nil , error)
            }
        }
    }
    
    func getRequest(_ urlString : String , params : [String : Any]? , headers : [String : String]? , callback : @escaping (JSON? , Error?)->()) {
        Alamofire.request(urlString, method:.get, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                print(value)
                callback(JSON(value) , nil)
            case .failure(let error):
                callback(nil , error)
            }
        }
    }
    
    func validateToken() -> String? {
        if let info = UserDefaults.standard.object(forKey: "info") as? [String : AnyObject] {
            if let token = info["Token"] as? String {
                return token
            }
        }
        return nil
    }
    
    func validateTokenWithBackId() -> (String , Int)? {
        if let info = UserDefaults.standard.object(forKey: "info") as? [String : AnyObject] {
            if let token = info["Token"] as? String {
                return (token , info["EmployeeId"] as! Int)
            }
        }
        return nil
    }

}
