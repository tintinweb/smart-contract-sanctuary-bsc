/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

pragma solidity 0.8.17;

interface UniswapBotInterface {
    function swapETHforTokenAndTransfer(address token, uint amount, address dst, uint slippage) external; 
}

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint) {
        return map.values[key];
    }

    function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        uint val
    ) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}



contract Queue {
    UniswapBotInterface UniswapBot;
    mapping (address => bool) isOwner;

    constructor() {
        isOwner[msg.sender] = true;
    }

    modifier owner {
        require(isOwner[msg.sender] == true); _;
    }

    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private map;

    function queueShitcoin(address shitcoin) public owner {
        map.set(shitcoin,1);
        
    }

    function removeShitcoin(address shitcoin) public owner {
        map.remove(shitcoin);
    }

    function loopThroughAndBuy(uint slippage, address dst, uint amount) public {
        if(amount == 0){
            amount = address(this).balance;
        }

        for (uint i = 0; i < map.size(); i++){
             address shitcoin = map.getKeyAtIndex(i);
             try UniswapBot.swapETHforTokenAndTransfer(shitcoin, amount, dst, slippage){
                 removeShitcoin(shitcoin);       
             }
             catch{}
                 
        }
    }

    function setUniswapBotContract(address cntrct) public owner {
        UniswapBot = UniswapBotInterface(cntrct);
    }

    function readMap(uint index) public view returns(address){
        return map.getKeyAtIndex(index);
    }

    function addOwner(address user) public owner{
        isOwner[user] = true;
    }


}