/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);



    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

  
}


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract BEP20PayToken is Ownable{

    address private _token = address(0x3adEB7a72ddDbAb5930708ee4823De142F7237E9); //测试链
    //address private _token = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); //正式链 BUSD

    uint private _nftScale = 23;
    uint public nftRemaining = 0;
    uint public nftCurrent = 0;

    uint private _staticScale = 10;
    uint public staticRemaining = 0;
    uint public staticCurrent = 0;

    uint private _competitionScale = 7;
    uint public competitionRemaining = 0;
    uint public competitionCurrent = 0;

    uint private _fundScale = 10;
    uint public fundRemaining = 0;
    uint public fundCurrent = 0;
    address[6] public fundAddress;
    address[18] public burnAddress;

    event PayToken(address indexed sender, uint  amount, uint id);

    event WithDrawalToken(address indexed sender, uint indexed amount);

    constructor() {
        for(uint i =0; i < fundAddress.length; i++){
            fundAddress[i] = address(0xf04E045bb1E5ae7a50016ab0eB89191689cD88c7);
        }
        for(uint i =0; i < burnAddress.length; i++){
            burnAddress[i] = address(0xf04E045bb1E5ae7a50016ab0eB89191689cD88c7);
        }
    }

    function payToken(address beneficiaryAddress,uint benefit_amount, uint amount,uint burn_amount, uint id) external returns(bool){

        require(0 < amount || 0 < benefit_amount, 'Amount: must be > 0');

        address sender = _msgSender();

        if (benefit_amount > 0){
            IERC20(_token).transferFrom(sender, beneficiaryAddress, benefit_amount);
        }

        if(amount > 0){                       
            uint lastamount = amount;
            //平均分配指定比例到基金钱包
            uint fundamount = amount * _fundScale / 100 / fundAddress.length;
            //计算剩余
            lastamount = lastamount - fundamount * fundAddress.length;
            for(uint i = 0; i < fundAddress.length; i++){
                IERC20(_token).transferFrom(sender, fundAddress[i], fundamount);
            }
            //累计当天分配
            nftCurrent = nftCurrent + amount * _nftScale / 100 ;
            staticCurrent = staticCurrent + amount * _staticScale / 100;
            competitionCurrent = competitionCurrent + amount * _competitionScale / 100;
            fundCurrent = fundCurrent + amount * _fundScale / 100;
            //剩余的放到合约里边
            IERC20(_token).transferFrom(sender, address(this), lastamount);
        }

        if(burn_amount > 0){                       
            //平均分配指定比例到烧伤钱包
            uint _amount = burn_amount / burnAddress.length;
            for(uint i = 0; i < burnAddress.length; i++){
                IERC20(_token).transferFrom(sender, burnAddress[i], _amount);
            }
        }        
        emit PayToken(sender, amount + benefit_amount + burn_amount, id);
        return true;
    }   

    function clear() external{
        nftRemaining = nftRemaining + nftCurrent;
        staticRemaining = staticRemaining + staticCurrent;
        competitionRemaining = competitionRemaining + competitionCurrent;
        fundRemaining = fundRemaining + fundCurrent;
        nftCurrent = 0;
        staticCurrent = 0;
        competitionCurrent = 0;
        fundCurrent = 0;
    }

    function getNft() external view returns(uint){
        return nftCurrent;
    }

    function getStatic() external view returns(uint){
        return staticCurrent;
    }

    function getCompetition() external view returns(uint){
        return competitionCurrent;
    }  

    function getFund() external view returns(uint){
        return fundCurrent;
    } 

    function withDrawalToken(address _address, uint amount) external onlyOwner returns(bool){

        IERC20(_token).transfer(_address, amount);

        emit WithDrawalToken(_address, amount);

        return true;
    }

    function setFundAddress(uint _index, address _address) external onlyOwner returns(bool){
        require(0 <= _index && _index < fundAddress.length, 'BEP20PayToken: index must be >= 0 and < 6');
        fundAddress[_index] = _address;
        return true;
    }

    function setBurnAddress(uint _index, address _address) external onlyOwner returns(bool){
        require(0 <= _index && _index < burnAddress.length, 'BEP20PayToken: index must be >= 0 and < 6');
        burnAddress[_index] = _address;
        return true;
    }
}