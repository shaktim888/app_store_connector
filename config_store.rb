#!/bin/env ruby
# -*- encoding: utf-8 -*-

require "bundler/setup"
require "io/console"

require "json"
require "openssl"
require "base64"

require "my_app_store_connect/client"
require "my_app_store_connect/object/type"
require "my_app_store_connect/object/attributes"
require "my_app_store_connect/object/properties"
require "my_app_store_connect/object/data"
require "my_app_store_connect/version"

require "my_app_store_connect/bundle_id_create_request"
require "my_app_store_connect/beta_tester_invitations_request"
require "my_app_store_connect/certificate_create_request"
require "my_app_store_connect/device_create_request"
require "my_app_store_connect/user_invitation_create_request"
require "my_app_store_connect/tf_invitation_create_request"
require "my_app_store_connect/profile_create_request"
require "my_app_store_connect/bundle_capability_create_request"
# print(".")
# =============================读取自定义配置文件=====================
def fileJSON
  fileConfig = File.read(File.join(".", "config", "output.json"))
  fileJSON = JSON.parse(fileConfig)
  return fileJSON
end

# =============================创建文件=====================
def create_file
  fileName = fileJSON["fileName"]
  filePath = File.join(".", "output") + "/" + fileName
  if !File.directory?(File.join(".", "output"))
    Dir.mkdir(File.join(".", "output"))
  end
  if !File.directory?(filePath)
    Dir.mkdir(filePath)
  end
  return fileName
end

# =============================创建存储mobileprovision文件目录=====================
def createmobileprovision_file
  fileprofileName = fileJSON["fileName"] + "/mobileprovision"
  fileprofilePath = File.join(".", "output") + "/" + fileprofileName
  if !File.directory?(fileprofilePath)
    Dir.mkdir(fileprofilePath)
  end
  return fileprofileName
end

# =============================判断p12是否已经存在本地=====================
def file_is_exist(fileName)
  filePath = File.join(".", "output") + "/" + fileJSON["fileName"] + "/" + fileName
  return File.exist?(filePath)
end

# =============================保存写入私钥文件key=====================
def export_KeyFile(ckey, filename)
  appKey_file = File.new(File.join(".", "output", filename, "app.key"), "w+")
  if appKey_file
    appKey_file.syswrite(ckey)
  end
end

# =============================保存写入CSR文件=====================
def export_csrFile(cpem, filename)
  csr_file = File.new(File.join(".", "output", filename, "csr.certificateSigningRequest"), "w+")
  if csr_file
    csr_file.syswrite(cpem)
  end
end

#==========================生成cer文件==========================
def export_cerFile(certificate, filename)
  certificateData = certificate["data"]
  certificateattributes = certificateData["attributes"]
  certificatecertificateContent = certificateattributes["certificateContent"]
  cer_decode = Base64.decode64(certificatecertificateContent)
  distribution_cerfile = File.new(File.join(".", "output", filename, "ios_distribution.cer"), "w+")
  if distribution_cerfile
    distribution_cerfile.syswrite(cer_decode)
  end
  # return cer_decode
end

#==========================将.cer转pem文件==========================
def export_pemFile(filename)
  ioscerdistrufile = File.read(File.join(".", "output", filename, "ios_distribution.cer"))
  cer_pem = OpenSSL::X509::Certificate.new ioscerdistrufile
  pem_file = File.new(File.join(".", "output", filename, "aps.pem"), "w+")
  if pem_file
    pem_file.syswrite(cer_pem)
  end
end

#==========================创建和导出p12证书==========================
def export_derp12(pass, key, cer, pfilename, filename)
  p12key = OpenSSL::PKey.read File.read(File.join(".", "output", filename, key))
  p12cert = OpenSSL::X509::Certificate.new File.read(File.join(".", "output", filename, cer))
  p12name = "" # not sure whether this is allowed
  pkcs12 = OpenSSL::PKCS12.create(pass, p12name, p12key, p12cert)
  pkcs12_der = pkcs12.to_der  # <= 获取证书格式

  p12_file = File.new(File.join(".", "output", filename, pfilename), "w+")

  if p12_file
    p12_file.syswrite(pkcs12_der)
  end
end

#==========================下载所有的mobileprovision描述文件==========================
def export_profiles(all_profiles, folderName, fileName)
  allProfilesArray = all_profiles["data"]

  allProfilesArray.collect { |profilesInfomation|
    attributesName = profilesInfomation["attributes"]
    profileName = attributesName["name"] + ".mobileprovision"
    if fileName
      profileName = fileName + ".mobileprovision"
    end
    profileContent = attributesName["profileContent"]

    profile_decode = Base64.decode64(profileContent)

    profile_file = File.new(File.join(".", "output", folderName, fileName, profileName), "w+")
    if profile_file
      profile_file.syswrite(profile_decode)
    end
  }
end

#==========================单个下载mobileprovision描述文件==========================
def export_profile(oneprofilesdata, folderName, fileName)
  oneProfilesattributes = oneprofilesdata["attributes"]
  profileName = oneProfilesattributes["name"] + ".mobileprovision"
  if fileName
    profileName = fileName + ".mobileprovision"
  end
  profileContent = oneProfilesattributes["profileContent"]

  profile_decode = Base64.decode64(profileContent)
  #============下载单个profile======
  profile_file = File.new(File.join(".", "output", folderName, profileName), "w+")
  if profile_file
    profile_file.syswrite(profile_decode)
  end
end

# =============================批量创建bundleId、开启推送服务、创建profile文件=====================
def create_bundleids_profile(appstoreconnect, profilecertificateType, profilecertificateId, filename)
  bundidid_file = File.new(File.join(".", "output", fileJSON["fileName"], "bundid.txt"), "w+")

  bundleidInfoArray = fileJSON["bundleidentifier"]
  createbundleiddata = nil
  bundleidInfoArray.collect { |bundleInfo|
    bundleName = bundleInfo["bundleId"].gsub(/[. -+=]/, "")
    allbundle = appstoreconnect.bundle_ids()
    createbundleiddata = allbundle["data"].find { |bundle_info_item| bundle_info_item["attributes"]["identifier"] == bundleInfo["bundleId"] }
    # createbundleid = appstoreconnect.bundle_id(id: bundleInfo["bundleId"])
    # puts(createbundleid)
    if !createbundleiddata
      puts "not exist bundleID:" + bundleInfo["bundleId"] + ", create it."
      createbundleid = appstoreconnect.create_bundle_id(
        name: bundleName,
        identifier: bundleInfo["bundleId"],
        platform: "IOS",
      )
      createbundleiddata = createbundleid["data"]
      if !createbundleiddata
        puts "create failed:"
        puts createbundleid
      end
    end
    if createbundleiddata
      # puts createbundleiddata
      bundlecapability_bundleType = createbundleiddata["type"]
      bundlecapability_bundleId = createbundleiddata["id"]
      # bundleIdattributes = createbundleiddata["attributes"]
      # bundleidprofileName = bundleIdattributes["name"]

      # 开启bundleid的推送功能
      appstoreconnect.create_capability(
        capabilityType: "PUSH_NOTIFICATIONS",
        relationships: {
          bundleId: {
            data: {
              type: bundlecapability_bundleType,
              id: bundlecapability_bundleId,
            },
          },
        },
      )
      if bundidid_file
        bundidid_file.syswrite("#{bundleInfo["bundleId"]}\n")
      end
      allprofile = appstoreconnect.bundle_id_profiles(id: bundlecapability_bundleId)
      profile = allprofile["data"].find { |item|
        item["attributes"]["name"] == bundleName
      }
      #开始创建profile文件
      if !profile
        getted_profile_info = appstoreconnect.create_profile(
          name: bundleName,
          profile_type: "IOS_APP_STORE",
          relationships: {
            bundleId: {
              data: {
                type: bundlecapability_bundleType,
                id: bundlecapability_bundleId,
              },
            },
            certificates: {
              data: [{
                type: profilecertificateType,
                id: profilecertificateId,
              }],
            },
          },
        )
        profile = getted_profile_info["data"]
      end
      #存入本地文件
      export_profile(profile, filename, bundleInfo["bundleidName"])
    end
  }
end

module AppStoreConnect
  @config = {
    analytics_enabled: true,
    schema: Schema.new(File.join(".", "config", "schema.json")),

    issuer_id: fileJSON["issuer_id"],
    key_id: fileJSON["key_id"],
    private_key: File.read(File.join(".", "config", fileJSON["private_key"])),
  }

  class << self
    attr_accessor :config
  end
end

def cert()
  # =============================字符串名字=====================
  p12FileName = "ios_distribution.p12"

  # =============================调用创建文件方法=====================
  create_file
  # =============================创建CSR文件=====================
  if !file_is_exist(p12FileName)
    key = OpenSSL::PKey::RSA.new(2048)
    digest = OpenSSL::Digest::SHA1.new()

    sub = OpenSSL::X509::Name.new()
    sub.add_entry("C", fileJSON["c"])
    sub.add_entry("CN", fileJSON["cn"])
    sub.add_entry("emailAddress", fileJSON["emailAddress"])

    csr = OpenSSL::X509::Request.new()
    csr.public_key = key.public_key  # <= 接受签署的公匙
    csr.subject = sub
    csr.sign(key, digest)  #签名认证
    csrpem = csr.to_pem  #返回pem
  end

  # =============================初始化使用AppStoreConnect=====================
  my_app_store_connect = AppStoreConnect::Client.new

  if file_is_exist(p12FileName)
    profile_certificateType = ""
    profile_certificateId = ""
    #====获取本地的cer文件
    getfilecer = File.read(File.join(".", "output", fileJSON["fileName"], "ios_distribution.cer"))
    encodeCert = Base64.encode64(getfilecer)

    createCertificates = my_app_store_connect.certificates

    createCertificatesdata = createCertificates["data"]

    createCertificatesdata.collect { |certcollect|
      certcollectattributes = certcollect["attributes"]
      certcollectcertificateContent = certcollectattributes["certificateContent"]
      #====获取服务器上的cer文件，转换对应的格式
      cerdecode = Base64.decode64(certcollectcertificateContent)
      cerencode = Base64.encode64(cerdecode)
      #====匹配服务器上的和本地的证书是否是同一个
      if cerencode == encodeCert
        profile_certificateType = certcollect["type"]
        profile_certificateId = certcollect["id"]
        puts "certificate Obtain success"
        break
      end
    }
  else

    #=============================创建证书=====================
    createCertificate = my_app_store_connect.create_certificate(
      certificate_type: "IOS_DISTRIBUTION",
      csr_content: csrpem,
    )
    certificateData = createCertificate["data"]
    if certificateData
      puts "certificate create success"
      # =============================获取创建profile的基本信息createCertificate信息=====================
      profile_certificateType = certificateData["type"]
      profile_certificateId = certificateData["id"]

      #==========================调用保存写入私钥文件key==========================
      export_KeyFile(key, create_file)
      #=============================调用保存写入CSR文件=====================
      export_csrFile(csrpem, create_file)
      #==========================调用生成cer文件==========================
      export_cerFile(createCertificate, create_file)
      #==========================调用将.cer转pem文件==========================
      export_pemFile(create_file)
      #==========================调用创建和下载p12证书==========================
      export_derp12("1", "app.key", "ios_distribution.cer", p12FileName, create_file)
      puts "PKCS12 create success"
    else
      puts "certificate create failed"
      puts createCertificate
    end
  end

  # =============================调用批量创建bundleId、开启推送服务、创建profile文件=====================
  create_bundleids_profile(my_app_store_connect, profile_certificateType, profile_certificateId, createmobileprovision_file)
  puts "profile create success"
  puts "all success"
end

def tf()

  # =============================初始化使用AppStoreConnect=====================
  my_app_store_connect = AppStoreConnect::Client.new

  apps = my_app_store_connect.apps()
  # puts apps
  if apps["data"]
    while true
      index = 0
      puts "请选择APP序号："
      apps["data"].collect { |curApp|
        puts "#{index}. #{curApp["attributes"]["name"]}"
        index = index + 1
      }
      selectIndex = STDIN.gets
      selectApp = apps["data"][selectIndex.to_i]
      puts "你选择的是：#{selectApp["attributes"]["name"]}"
      app_builds = my_app_store_connect.app_builds(id: selectApp["id"])
      if (app_builds["data"])
        if (app_builds["data"].length == 0)
          puts "当前应用无可用版本进行测试"
          break
        end
        # puts app_builds["data"]
        while true
          index = 0
          puts "请选择进行测试的版本："
          app_builds["data"].collect { |app_build|
            puts "#{index}. #{app_build["attributes"]["version"]}#{app_build["attributes"]["processingState"] == "VALID" ? "" : " 此版本不可用"}"
            index = index + 1
          }
          puts "#. 返回到上一层选择"
          selectIndex = STDIN.gets
          if selectIndex.include? "#"
            break
          end
          selectBuild = app_builds["data"][selectIndex.to_i]
          define_method :inviteUser do |emailAddr|
            puts "正在添加用户#{emailAddr}"
            testerData = my_app_store_connect.create_beta_testers({
              email: emailAddr,
              firstName: "firstNameTest",
              lastName: "lastNameTest",
              relationships: {
                builds: {
                  data: [{
                    type: "builds",
                    id: selectBuild["id"],
                  }],
                },
              },
            })
            if (testerData["data"])
              tester = testerData["data"]
              puts "正在对#{emailAddr}发送邀请"
              sended = my_app_store_connect.betaTesterInvitations(relationships: {
                                                                    app: {
                                                                      data: {
                                                                        type: "apps",
                                                                        id: selectApp["id"],
                                                                      },
                                                                    },
                                                                    betaTester: {
                                                                      data: {
                                                                        type: "betaTesters",
                                                                        id: tester["id"],
                                                                      },
                                                                    },
                                                                  })
              if sended["errors"]
                puts "邀请#{emailAddr}出错:"
                puts sended
              else
                puts "邀请#{emailAddr}成功。请去邮箱查看"
              end
            else
              puts "出现错误"
              puts testerData
            end
          end

          # 邀请的逻辑
          allTesters = my_app_store_connect.beta_testers()
          if allTesters["data"]
            isFound = false
            if allTesters["data"].length > 0
              allTesters["data"].collect { |tester|
                # puts tester["id"]
                if fileJSON["emailAddress"] == tester["attributes"]["email"]
                  isFound = true
                  puts "正在删除用户#{tester["attributes"]["email"]}"
                  my_app_store_connect.delete_beta_tester(id: tester["id"])
                  inviteUser(tester["attributes"]["email"])
                end
              }
            end
            if !isFound
              inviteUser(fileJSON["emailAddress"])
            end
            return
          else
            puts "出现错误："
            puts allTesters
          end
        end
      else
        puts "出现错误："
        puts app_builds
      end
    end
  end
end

if ARGV.length > 0
  ARGV.each do |param|
    if param == "--cert"
      cert
    elsif param == "--tf"
      tf
    end
  end
else
  cert
end
