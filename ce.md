🌐 GLinet BE3600 一键工具箱
为 GL-iNet BE3600 提供一键式增强脚本，包含 iStoreOS 风格化、主题安装、风扇温控、AdGuardHome 管理等功能。
本仓库对上游脚本进行本地化托管，确保在上游失效时仍可稳定使用。

🚀 一键安装命令（SSH 直接复制执行）
sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/lightanbaby1131-alt/GLinet/master/be3600.sh)"
📄 脚本 Raw 地址
text
https://raw.githubusercontent.com/lightanbaby1131-alt/GLinet/master/be3600.sh
🧩 功能菜单（脚本内置）
GL-iNet BE3600 一键 iStoreOS 风格化（64 位）

安装 Argon 紫色主题

单独安装 iStore 商店

隐藏首页格式化按钮

自定义风扇启动温度

启用或关闭 AdGuardHome 广告拦截

安装个性化 UI 辅助插件（by VMatrices）

🔄 自动同步上游（GitHub Actions）
本仓库使用 GitHub Actions 自动同步上游脚本：

上游地址：
https://mt3000.netlify.app/be3600.sh

同步频率：
每 12 小时自动检查一次

同步逻辑：

上游可访问且文件非空 → 才会同步

上游失效 / 404 / 空文件 → 跳过同步，不覆盖本地文件

内容无变化 → 不提交

内容有变化 → 自动更新并提交

这样可以确保：
即使上游失效，本仓库仍保留最后一个可用版本。

📦 文件结构
代码
GLinet/
 ├── be3600.sh                 # 本地化一键脚本
 └── .github/
      └── workflows/
           └── sync-be3600.yml # 自动同步上游的工作流
🙏 致谢
本脚本基于以下项目进行本地化托管与增强：

@wukongdaily

GL-iNet 社区贡献者

iStoreOS / LinkEase 生态开发者
