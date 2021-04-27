 //SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./ItemManager.sol";

contract Item {

    uint public priceInWei;
    uint public paidWei;
    uint public index;

    ItemManager private parentContract;

    constructor(ItemManager _parentContract, uint _priceInWei, uint _index) {
        priceInWei = _priceInWei;
        index = _index;
        _parentContract = parentContract;
    }

    receive() external payable {
        // to not get too much or not enough, which is both bad
        require(priceInWei == msg.value, "We don't support partial payments");
        require(paidWei == 0, "Item has already been paid for.");
        
        paidWei += msg.value;
        (bool success, ) = address(parentContract).call{value: msg.value}(abi.encodeWithSignature("triggerPayment(uint256)", index));
        require(success, "Payment did not work.");
    }
}
