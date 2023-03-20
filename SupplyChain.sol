// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

contract SupplyChain {
    // struct to represent a product
    struct Product {
        uint id;
        string name;
        address manufacturer;
        address supplier;
        address owner;
        address shipping;
        uint price;
        int status; // -1 = breakdown, 0 = created, 1 = in transit, 2 = received
        string breakdownReason;
    }

    // mapping from product IDs to product structs
    mapping(uint => Product) public products;

    // event to be emitted when a product's status is updated
    event ProductStatusChanged(uint id, int status);

    // event to be emitted when there is a shipping breakdown
    event ShippingBreakdown(uint id, string reason);

    // function to create a new product
    function createProduct(uint id, string memory name, address manufacturer, address supplier, uint price) public {
        // create a new product struct and store it in the mapping
        products[id] = Product(id, name, manufacturer, supplier, manufacturer, address(0), price, 0, "No Issues");
    }

    // function to update the shipping company for a product
    function updateShipping(uint id, address shipping) public {
        Product storage product = products[id];

        // check that the caller is the manufacturer of the product
        require(msg.sender == product.manufacturer, "Only the manufacturer can update the shipping company for a product");

        // update the product's shipping company
        product.status = 1;
        product.breakdownReason = "No Issues";
        product.shipping = shipping;
    }

    // function to update the status of a product
    function changeStatus(uint id, int status) public {
        Product storage product = products[id];

        // check that the caller is the manufacturer of the product
        require(msg.sender == product.manufacturer, "Only the manufacturer can change the status of a product");

        // update the product's status and emit an event
        product.status = status;
        emit ProductStatusChanged(id, status);
    }

    // function to transfer ownership of a product
    function transferOwnership(uint id, address newOwner) public {
        Product storage product = products[id];

        // check that the caller is the current owner of the product
        require(msg.sender == product.owner, "Only the owner can transfer ownership of a product");
        product.owner = newOwner;
    }

    // function to report a shipping breakdown
    function reportShippingBreakdown(uint id, string memory reason) public {
        Product storage product = products[id];

        require(product.status == 1, "The product must be in transit to report a shipping breakdown");

        // check that the caller is the shipping company for the product
        require(msg.sender == product.shipping, "Only the shipping company can report a shipping breakdown");

        product.status = -1;
        product.breakdownReason = reason;

        // emit the ShippingBreakdown event with the product ID and reason
        emit ShippingBreakdown(id, reason);
    }
}