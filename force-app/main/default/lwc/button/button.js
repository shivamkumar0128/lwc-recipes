import { LightningElement } from 'lwc';

export default class Button extends LightningElement {

    handleClick(event){
        event.preventDefault();
        console.log('Button clicked', event.target.label);
    }
}