import { Command, CommandContribution, CommandRegistry, MenuContribution, MenuModelRegistry, MessageService } from '@theia/core/lib/common';
export declare const HelloWorldTestCommand: Command;
export declare class HelloWorldTestCommandContribution implements CommandContribution {
    private readonly messageService;
    constructor(messageService: MessageService);
    registerCommands(registry: CommandRegistry): void;
}
export declare class HelloWorldTestMenuContribution implements MenuContribution {
    registerMenus(menus: MenuModelRegistry): void;
}
//# sourceMappingURL=hello-world-test-contribution.d.ts.map