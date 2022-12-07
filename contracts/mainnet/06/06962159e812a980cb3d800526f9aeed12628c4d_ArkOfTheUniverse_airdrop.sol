/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

/**
 *Submitted for verification at Etherscan.io on 2022-12-04
*/

//SPDX-License-Identifier: MIT

/**

    ARK OF THE UNIVERSE
    With a space theme and an economy with 4 sectors, it aims to serve any type of investor. 
    3D Spaceship Game, the future PVP with MOBA mechanics and the amazing MMORPG.

    www.arkoftheuniverse.com
    https://twitter.com/ArkOfTheUniv
    https://t.me/arkoftheuniverseofficialBR


    @dev blockchain:
    https://twitter.com/ItaloH_SA
    https://t.me/italo_blockchain

*/

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Is impossible to renounce the ownership of the contract");
        require(newOwner != address(0xdead), "Is impossible to renounce the ownership of the contract");

        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


library SafeMath {

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

}


interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




contract ArkOfTheUniverse_airdrop is Ownable  {
    using SafeMath for uint256;

    mapping(address => bool) public mappingAuth;


    constructor() {

        mappingAuth[owner()] = true;
    }

    receive() external payable {}
    
    modifier onlyAuth() {
        require(_msgSender() == owner() || mappingAuth[_msgSender()], "Without permission");
        _;
    }

    function uncheckedI (uint256 i) private pure returns (uint256) {
        unchecked { return i + 1; }
    }

    function airdrop (
        address[] memory addresses, 
        uint256[] memory tokens) external onlyAuth() {
        for (uint i = 0; i < addresses.length; i = uncheckedI(i)) {  
            IERC20(0xdF4b14021C9A9e65d2e6881CBE3063E0F45cf133).transferFrom(msg.sender,addresses[i],tokens[i]);
        }

    }


}