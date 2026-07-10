import { LightningElement } from 'lwc';

export default class ButtonMenu extends LightningElement {
    selectedItemValue;
    handleSelect(event){
        event.preventDefault();
        this.selectedItemValue = event.detail.value;
    }

    selectedItemValues;
    handleSelected(event){
        event.preventDefault();
        this.selectedItemValues = !this.selectedItemValues;
    }
}