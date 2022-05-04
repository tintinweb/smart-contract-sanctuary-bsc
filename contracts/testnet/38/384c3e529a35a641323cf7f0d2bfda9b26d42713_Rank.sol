//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
 
// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
   
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

   
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
  
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }


    function toBytesNickJohnson(uint256 x) internal pure   returns(bytes memory b) {
        b = new bytes(32);
        assembly { mstore(add(b, 32), x) }
    }
 
    function getStr(uint256 playChoice) internal pure  returns(string memory s) {
        bytes memory c = toBytesNickJohnson(playChoice);
        return string(c);
    }

}

library Rank {
    using SafeMath for uint256;
    //最大排250名
    uint8 constant maxRank = 250;
    struct rankData {
        address _key;
        uint256 _value;
    }
    struct  RankObj  {
       // mapping(address => uint256)[]   _entries;
        rankData[] _entries;
        mapping (address => uint ) _indexes;
    }
    function _add(RankObj storage data, address _address,uint256 _number) internal   {
        uint len = data._entries.length;
        //原来不空
        if (len < 1){
            data._entries.push(rankData({_key:_address,_value:_number}));
            data._indexes[_address] = 1;
            return;
        }
        //最后一个元素
        if (data._entries[len-1]._value  > _number){
            if (len < maxRank){
                data._entries.push(rankData({_key:_address,_value:_number}));
                data._indexes[_address] = len+1;
            }
        }else{
            uint index = 0;
            //在中间插入新元素
            for (uint i= len-1; i>0;i--){
                if (data._entries[i-1]._value  > _number ) {
                    index = i;
                    break;
                }
            }
            //最后一条记录后移一位
            data._entries.push(rankData({_key:data._entries[len-1]._key,_value:data._entries[len-1]._value}));
            data._indexes[ data._entries[len-1]._key]++;
            //data._entries
            //index后的依次后移一位
            for (uint i= len-1;i > index;i--){
                data._indexes[data._entries[i]._key]++;
                data._entries[i]._key = data._entries[i-1]._key;
                data._entries[i]._value = data._entries[i-1]._value;
            }
            data._indexes[_address] = index;
            data._entries[index]._key = _address ;
            data._entries[index]._value = _number;
        }
        return  ;
    }

    function _update(RankObj storage data, address _address,uint256 _number,uint _index) internal   {
       // uint curindex= 0;
        for (uint i=_index-1;i>0;i--){
            if (data._entries[i]._value < _number) {
               // data._indexes[_address] = index;
                data._entries[i+1]._key = data._entries[i]._key ;
                data._entries[i+1]._value = data._entries[i]._value;
                data._indexes[data._entries[i+1]._key] = i+1;
            }else{ //> or =
                data._entries[i]._key = _address;
                data._entries[i]._value = _number;
                data._indexes[_address] = i;
                break;
            }
         }
    }

    function updateRank(RankObj storage data, address _address,uint256 _number) internal { 
        //新增
        if (data._indexes[_address] == 0){
            //data._add(_address,_number);
            _add(data,_address,_number);
        }else{
            if (data._entries[data._indexes[_address]-1]._value == _number){
                return;
            } 
        //    require(data._entries[data._indexes[_address]-1]._value < _number,"Less than the original value");
            require(data._entries[data._indexes[_address]-1]._value < _number, _number.getStr());
            //已经是排第一个
            if (data._indexes[_address] == 1){
                data._entries[0]._value = _number;
            }else{
                _update(data,_address,_number,data._indexes[_address]);
            }
        }
    }

    function length(RankObj storage data) internal view returns(uint) {
        return data._entries.length;
    }
 }