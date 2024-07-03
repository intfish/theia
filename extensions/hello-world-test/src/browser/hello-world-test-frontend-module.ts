/**
 * Generated using theia-extension-generator
 */
import { HelloWorldTestCommandContribution, HelloWorldTestMenuContribution } from './hello-world-test-contribution';
import { CommandContribution, MenuContribution } from '@theia/core/lib/common';
import { ContainerModule } from '@theia/core/shared/inversify';

export default new ContainerModule(bind => {
    // add your contribution bindings here
    bind(CommandContribution).to(HelloWorldTestCommandContribution);
    bind(MenuContribution).to(HelloWorldTestMenuContribution);
});
