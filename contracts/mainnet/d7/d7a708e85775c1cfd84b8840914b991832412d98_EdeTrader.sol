/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IVault {
    function increasePosition(address _account, address _collateralToken, address _indexToken, uint256 _sizeDelta, bool _isLong) external;
    function decreasePosition(address _account, address _collateralToken, address _indexToken, uint256 _collateralDelta, uint256 _sizeDelta, bool _isLong, address _receiver) external returns (uint256);
    function getMaxPrice(address _token) external view returns (uint256);
    function getMinPrice(address _token) external view returns (uint256);
}

/**
 * @title Owner
 * @dev Set & change owner
 */
contract EdeTrader {

    address private owner;
    //address public weth;
    address public vault;

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    /**
     * @dev Set contract deployer as owner
     */
    constructor(address _vault) {
        vault = _vault;
        //weth = _weth;
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address){
        return owner;
    }

    function increasePosition(uint256 price, address _account, address _collateralToken, address _indexToken, uint256 _sizeDelta, uint256 _collateralDelta,  bool _isLong) external isOwner {
        if(price!=0){
            require(price==IVault(vault).getMinPrice(_indexToken), "invalid price");
        }
        IERC20(_collateralToken).transferFrom(_account, vault, _collateralDelta);
        IVault(vault).increasePosition(_account, _collateralToken, _indexToken, _sizeDelta, _isLong);
    }
    function decreasePosition(uint256 price, address _account, address _collateralToken, address _indexToken, uint256 _collateralDelta, uint256 _sizeDelta, bool _isLong, address _receiver) external isOwner /*returns (uint256)*/ {
        if(price!=0){
            require(price==IVault(vault).getMinPrice(_indexToken), "invalid price");
        }
        //return 
        IVault(vault).decreasePosition(_account, _collateralToken, _indexToken, _collateralDelta, _sizeDelta, _isLong, _receiver);
    }
}