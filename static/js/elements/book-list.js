
export class BookList extends HTMLElement {

    connectedCallback() {
        fetch(url, {
            headers: {
                accept: 'application/json',
                authorization: `Bearer ${keycloak.token}`,
            },
        }).then(
            response => response.json() // if the response is a JSON object
        ).then(
            success => this.textContent = success // Handle the success response object
        ).catch(
            error => console.log(error) // Handle the error response object
        );
    }
}

customElements.define('book-list', CurrentDate);
