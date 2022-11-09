/**
 *Submitted for verification at BscScan.com on 2022-11-09
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

    address private _token = address(0x55d398326f99059fF775485246999027B3197955); 

    uint private _nftScale = 46;
    uint public nftRemaining = 0;
    uint public nftCurrent = 0;

    uint private _staticScale = 20;
    uint public staticRemaining = 0;
    uint public staticCurrent = 0;

    uint private _competitionScale = 14;
    uint public competitionRemaining = 0;
    uint public competitionCurrent = 0;

    uint private _fundScale = 20;
    uint public fundRemaining = 0;
    uint public fundCurrent = 0;
    address[6] public fundAddress;
    address[18] public burnAddress;
    
    event PayToken(address indexed sender, uint  amount, uint id);
    event Distribute(uint  amount);
    event WithDrawalToken(address indexed sender, uint indexed amount);

    constructor() {
        fundAddress[0] = address(0x1eFDfA87356941426a08Bc1941020D1393957A11);
        fundAddress[1] = address(0x6348325304cF4d913cc871bEeCFa42F223B71237);
        fundAddress[2] = address(0xBA123fd66bAF10f1653557f595dFF9c771dF83C5);
        fundAddress[3] = address(0x65B081F30f42e9d66d52C13397a870e07412476E);
        fundAddress[4] = address(0x06A1a89120D4e480e0E2FA0eA77ce944CD3c8CE0);
        fundAddress[5] = address(0x001406a8f72cFECf87503a95998192Ea7E1e620B);

        burnAddress[0] = address(0xd525C05Cc6B8774AB8f2de6b293F22245d8261c6);
        burnAddress[1] = address(0x2B8B9eF9B9926257b685f57EDFb6b42917aea5Fa);
        burnAddress[2] = address(0x0A8B48F21eF48C2bC3D73b86CCbf78706Def8874);
        burnAddress[3] = address(0x9d5685B4CBD734ddd40A3d47e99c41b118762Bdf);
        burnAddress[4] = address(0xb60a4D050EF55C576d62ACf5c713C037bC5f0e6D);
        burnAddress[5] = address(0xBBe1F67575e4233eea0885B86F03824b78751805);
        burnAddress[6] = address(0x1F22959ff17518f85D10f2049963b401258e5C07);
        burnAddress[7] = address(0x7D93DC7AB6D46C16Ee71A23207e3E5CA3c3Dc8f0);
        burnAddress[8] = address(0xeBc700FdA4404d8562dF4c9c1B2B8AA8597e2C54);
        burnAddress[9] = address(0xb6a07aEC9e7E7aC157FD3D2137b763367322Eb4f);
        burnAddress[10] = address(0x5c527A392d60f0626d9e7A16936f6bcB284375DC);
        burnAddress[11] = address(0xA33d2429F0372983f0C1F32D6b8B7de93fcA64CE);
        burnAddress[12] = address(0x0642237F2f53F54984eaaFC8f053856a257ac25A);
        burnAddress[13] = address(0x8E05Cb8CDE78dF9b7836ac476db3d197daFB276E);
        burnAddress[14] = address(0x71F2b544dDB455835b887813e07419D42ecC779D);
        burnAddress[15] = address(0xEeAa0405271D1d338f50F7C78a21eC52f6A842C4);
        burnAddress[16] = address(0x23020DfDA023E62D0A2c9dEcC78EC19B4a60fE9f);
        burnAddress[17] = address(0xc1D8d171D5813e9BC8179B926e5d4Cb90294675B);
    }

    function withdraw() public payable {
        payable(msg.sender).transfer(address(this).balance);
    }

    function payToken(uint amount, uint id) payable external returns(bool){
        address sender = _msgSender();

        payable(owner()).transfer(msg.value);

        IERC20(_token).transferFrom(sender, address(this), amount);

        emit PayToken(sender, amount, id);
        return true;
    }

    function distribute(address beneficiaryAddress,uint benefit_amount, uint amount,uint burn_amount) external onlyOwner returns(bool){

        require(0 < amount || 0 < benefit_amount || 0 < burn_amount, 'Amount: must be > 0');

        if (benefit_amount > 0){
            IERC20(_token).transfer(beneficiaryAddress, benefit_amount);
        }

        if(amount > 0){                       
            uint lastamount = amount;
            //平均分配指定比例到基金钱包
            uint fundamount = amount * _fundScale / 100 / fundAddress.length;
            //计算剩余
            lastamount = lastamount - fundamount * fundAddress.length;
            for(uint i = 0; i < fundAddress.length; i++){
                IERC20(_token).transfer(fundAddress[i], fundamount);
            }
            //累计当天分配
            nftCurrent = nftCurrent + amount * _nftScale / 100 ;
            staticCurrent = staticCurrent + amount * _staticScale / 100;
            competitionCurrent = competitionCurrent + amount * _competitionScale / 100;
            fundCurrent = fundCurrent + amount * _fundScale / 100;
        }

        if(burn_amount > 0){                       
            //平均分配指定比例到烧伤钱包
            uint _amount = burn_amount / burnAddress.length;
            for(uint i = 0; i < burnAddress.length; i++){
                IERC20(_token).transfer(burnAddress[i], _amount);
            }
        }        
        emit Distribute(amount + benefit_amount + burn_amount);
        return true;
    }

    function clear() external{
        nftRemaining = nftRemaining + nftCurrent;
        staticRemaining = staticRemaining + staticCurrent;
        competitionRemaining = competitionRemaining + competitionCurrent / 2;
        fundRemaining = fundRemaining + fundCurrent;
        nftCurrent = 0;
        staticCurrent = 0;
        competitionCurrent = competitionCurrent / 2;
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