//
//  File.swift
//  
//
//  Created by Danila on 08.02.2022.
//

import Vapor
import telegram_vapor_bot

final class DefaultBotHandlers {

    static func addHandlers(app: Vapor.Application, bot: TGBotPrtcl) {
        defaultHandler(app: app, bot: bot)
        commandPingHandler(app: app, bot: bot)
        
    }

    /// add handler for all messages unless command "/ping"
    private static func defaultHandler(app: Vapor.Application, bot: TGBotPrtcl) {
        let handler = TGMessageHandler(filters: (.all && !.command.names(["/ping"]))) { update, bot in
            
            if let mediaID = update.message?.photo?.last?.fileId {
                try? bot.getFile(params: TGGetFileParams(fileId: mediaID)).whenSuccess({ file in
                    guard let filePath = file.filePath else {
                        return
                    }
                    let url = "https://api.telegram.org/file/bot\(tgApi)/\(filePath)"
                    try? update.message?.reply(text: url, bot: bot)
                })
            }
            
        }
        bot.connection.dispatcher.add(handler)
    }

    /// add handler for command "/ping"
    private static func commandPingHandler(app: Vapor.Application, bot: TGBotPrtcl) {
        let handler = TGCommandHandler(commands: ["/ping"]) { update, bot in
            try update.message?.reply(text: "pong", bot: bot)
        }
        bot.connection.dispatcher.add(handler)
    }
    
}
