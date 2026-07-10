import { LightningElement } from 'lwc';

export default class ComboBoxs extends LightningElement {

    value;
    options = [
        { label: 'New', value: 'New' },
        { label: 'In Progress', value: 'InProgress' },
        { label: 'Pending', value: 'Pending' },
        {label: 'Completed', value: 'Completed' },
        {label: 'Closed', value: 'Closed' }
    ];

    handleChange(event) {
        this.value = event.detail.value;
    }
}