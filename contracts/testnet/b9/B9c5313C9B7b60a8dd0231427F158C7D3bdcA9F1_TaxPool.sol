/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// SPDX-License-Identifier: UNLISCENSED

pragma solidity ^0.8.4;



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    constructor() {
        _transferOwnership(_msgSender());
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }


    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


interface IERC20 {

    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}


contract TaxPool is Ownable{
    
    IERC20 busd;
    IERC20 native;

    uint256 a = 500;
    uint256 b = 10000;
    
    address mint_pool;
    mapping(address=>uint256) nextRequestAt;

    constructor () {
        busd = IERC20(0xB31e26356521296064E792618628cA1C834B7882);   // BUSD busd
        native = IERC20(0x342d2E24b5D317615346f3012a8b5ACE8aD0309c); // House Stable busd        
        
    }   

    function SetMintPoolAddress(address _mint_pool) public onlyOwner {
        mint_pool = _mint_pool;
    }
    
    function MintPoolAddress() public view virtual returns (address) {
        return mint_pool;
    }
    
    function TradeForShare(uint256 Amount) public {
        require(Amount <= 1000);
        require(nextRequestAt[msg.sender] < block.timestamp);
        require(busd.balanceOf(address(this)) >= (Amount + ((Amount * a) / b)) * 10**native.decimals());
        require(native.balanceOf(msg.sender) >= Amount * 10**native.decimals());

        uint256 reward = ((Amount * a) / (b));
        
        nextRequestAt[msg.sender] = block.timestamp + (60 seconds);

        busd.transfer(msg.sender, (Amount + reward) * 10**busd.decimals());
    
        native.transferFrom(msg.sender, mint_pool, Amount * 10**native.decimals());

    }





}