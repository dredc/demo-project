import { LightningElement, api } from 'lwc';

export default class MyPortfolio extends LightningElement {

    @api imageURL = '';

    getImageURL() {
        return this.imageURL;
    }
}