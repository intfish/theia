"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.HelloWorldTestMenuContribution = exports.HelloWorldTestCommandContribution = exports.HelloWorldTestCommand = void 0;
const inversify_1 = require("@theia/core/shared/inversify");
const common_1 = require("@theia/core/lib/common");
const browser_1 = require("@theia/core/lib/browser");
exports.HelloWorldTestCommand = {
    id: 'HelloWorldTest.command',
    label: 'Say Hello'
};
let HelloWorldTestCommandContribution = class HelloWorldTestCommandContribution {
    constructor(messageService) {
        this.messageService = messageService;
    }
    registerCommands(registry) {
        registry.registerCommand(exports.HelloWorldTestCommand, {
            execute: () => this.messageService.info('Hello World!')
        });
    }
};
HelloWorldTestCommandContribution = __decorate([
    (0, inversify_1.injectable)(),
    __param(0, (0, inversify_1.inject)(common_1.MessageService)),
    __metadata("design:paramtypes", [common_1.MessageService])
], HelloWorldTestCommandContribution);
exports.HelloWorldTestCommandContribution = HelloWorldTestCommandContribution;
let HelloWorldTestMenuContribution = class HelloWorldTestMenuContribution {
    registerMenus(menus) {
        menus.registerMenuAction(browser_1.CommonMenus.EDIT_FIND, {
            commandId: exports.HelloWorldTestCommand.id,
            label: exports.HelloWorldTestCommand.label
        });
    }
};
HelloWorldTestMenuContribution = __decorate([
    (0, inversify_1.injectable)()
], HelloWorldTestMenuContribution);
exports.HelloWorldTestMenuContribution = HelloWorldTestMenuContribution;
//# sourceMappingURL=hello-world-test-contribution.js.map