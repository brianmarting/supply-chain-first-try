//SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./Item.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ItemManager is Ownable {

    enum SupplyChainStatus {
        Created, Paid, Delivered
    }

    struct SupplyItem {
        string id;
        Item item;
        SupplyChainStatus status;
    }

    mapping(uint => SupplyItem) public items;

    uint index;

    event SupplyChainStatusChange(uint indexed _itemIndex, uint _status, address _address);

    function createItem(string memory _id, uint _priceInWei) public onlyOwner {
        SupplyItem storage supplyItem = items[index];
        supplyItem.status = SupplyChainStatus.Created;
        supplyItem.id = _id;
        Item item = new Item(this, _priceInWei, index);
        supplyItem.item = item;

        emit SupplyChainStatusChange(index, uint(supplyItem.status), address(supplyItem.item));
        index++;
    }

    function triggerPayment(uint _index) public payable {
        Item item = items[_index].item;
        require(address(item) == msg.sender, "Only items are allowed to updated themselves.");
        require(item.priceInWei() <= msg.value, "Price is higher than sent amount.");
        require(items[_index].status == SupplyChainStatus.Created, "Item is already paid for or has been delivered.");
        items[_index].status = SupplyChainStatus.Paid;
        emit SupplyChainStatusChange(_index, uint(items[_index].status), address(items[index].item));
    }

    function triggerDelivery(uint _index) public onlyOwner {
        require(items[_index].status == SupplyChainStatus.Paid, "Item has not yet been paid for or has been delivered.");
        items[_index].status = SupplyChainStatus.Delivered;
        emit SupplyChainStatusChange(_index, uint(items[_index].status), address(items[index].item));
    }
}
