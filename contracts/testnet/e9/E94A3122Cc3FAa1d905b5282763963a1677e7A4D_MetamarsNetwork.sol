/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// SPDX-License-Identifier: MIT
// File: contracts/IMetamarsNFT.sol


pragma solidity ^0.8.4;


interface IMetamarsNFT{

    function safeMintAdmin(address to, uint256 tokenId) external;

}
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: contracts/MetamarsNetwork.sol


pragma solidity ^0.8.4;




contract MetamarsNetwork is Ownable {

    struct Investor{
        bool registered;
        address parentAddress;
        address childAddressLeft;
        address childAddressRight;
        uint totalInvested;
        uint totalInvestedBranchLeft;
        uint totalInvestedBranchRight;
        uint joinedAt;
        uint matrixReward;
        uint binaryReward;
        uint withdrawn;
    }



    IERC20 private token;
    IMetamarsNFT private nft;

    address private tokenAddress;
    address private nftAddress;

    mapping(address=>Investor) public investors;
    uint256 public numInvestor;
    mapping(address=>uint[]) public addressToNftItems;
    uint256 public totalInvestment;
    uint256 public totalReward;
    uint256 public totalWithdrawn;




    uint8[] public MATRIX_REWARDS=[1,1,1,1,1,2,2,2,2,2,3,3,3,3,3];
    uint8 public BINARY_REWARD=20;



    constructor() {
        investors[msg.sender]=Investor(
            true,
            address(0),
            address(0),
            address(0),
            0,
            0,
            0,
            block.timestamp,
            0,
            0,
            0
        );
        numInvestor++;
    }


  //============================================================================

    function hasToken() private view returns (bool){
        return tokenAddress!=address(0);
    }

    function hasNft() private view returns (bool){
        return nftAddress!=address(0);
    }

  //============================================================================

    function setTokenContract(address _tokenAddress) public onlyOwner onlyIfTokenNotSet{
        tokenAddress=_tokenAddress;
        token=IERC20(tokenAddress);
    }

    function setNftContract(address _nftAddress) public onlyOwner onlyIfNftNotSet{
        nftAddress=_nftAddress;
        nft=IMetamarsNFT(nftAddress);
    }

    function getNftPrice(uint256 _tokenId) public pure returns (uint256){
        if(_tokenId<1000){
            return 1000;
        }
        return 1500;
    }


    function invest(uint256 _tokenId,address parent, uint leftOrRight) public onlyIfTokenSet onlyIfNftSet{

        require(parent!=address(0),"Invalid parent address");
        require(parent!=msg.sender,"Invalid parent address, same as sender");
        require(investors[parent].registered,"Parent address is not registered");
        require(leftOrRight==0 || leftOrRight==1 ,"Invalid branch");

        uint256 _price=getNftPrice(_tokenId);

        require(token.allowance(msg.sender,address(this))>=_price,"Insufficient token allowance");
        require(token.balanceOf(msg.sender)>=_price,"Insufficient token balance");

        if(investors[msg.sender].registered){
            investors[msg.sender].totalInvested +=_price;
        }else{
            if(leftOrRight==0){         //left
                require(investors[parent].childAddressLeft==address(0),"The position is not free to register");
                investors[parent].childAddressLeft=msg.sender;
            }else if(leftOrRight==1){   //right
                require(investors[parent].childAddressRight==address(0),"The position is not free to register");
                investors[parent].childAddressRight=msg.sender;
            }
            investors[msg.sender]=Investor(
                true,
                parent,
                address(0),
                address(0),
                _price,
                0,
                0,
                block.timestamp,
                0,
                0,
                0
            );
            numInvestor++;
        }
        
        uint8 counter=0;
        do{
            
            if(leftOrRight==0){         //left
                investors[parent].totalInvestedBranchLeft += _price;
            }else if(leftOrRight==1){   //right
                investors[parent].totalInvestedBranchRight += _price;
            }


            //matrix reward
            uint _matrixReward;
            if(counter<MATRIX_REWARDS.length){
                _matrixReward = _price * MATRIX_REWARDS[counter] / 100;
                investors[parent].matrixReward += _matrixReward;
                totalReward +=_matrixReward;
            }

            //binary reward
            uint _binaryReward;
            if(investors[parent].totalInvestedBranchLeft>investors[parent].totalInvestedBranchRight){
                _binaryReward = investors[parent].totalInvestedBranchRight * BINARY_REWARD / 100 - investors[parent].binaryReward; 
                investors[parent].binaryReward += _binaryReward; 
                totalReward +=_binaryReward;
            }else{
                _binaryReward = investors[parent].totalInvestedBranchLeft * BINARY_REWARD / 100 - investors[parent].binaryReward; 
                investors[parent].binaryReward += _binaryReward; 
                totalReward +=_binaryReward;
            }


            if(investors[parent].parentAddress==address(0)){
                break;
            }
            counter++;
            parent=investors[parent].parentAddress;
        } while (true);
        

        token.transferFrom(msg.sender,address(this),_price);
        nft.safeMintAdmin(msg.sender,_tokenId);
        addressToNftItems[msg.sender].push(_tokenId);
        totalInvestment += _price;
    }

    function withdraw() public onlyInvestor{
        uint withdrawValue=investors[msg.sender].matrixReward + investors[msg.sender].binaryReward - investors[msg.sender].withdrawn;
        require(withdrawValue>0,"Nothing to withdraw!");
        token.transfer(msg.sender,withdrawValue);
        investors[msg.sender].withdrawn += withdrawValue;
        totalWithdrawn +=withdrawValue;
    }



    //======================================================================================
    // MODIFIERS
    //======================================================================================

    modifier onlyIfTokenSet(){
        require(hasToken(),"Set token before doing this action");
        _;
    }

    modifier onlyIfTokenNotSet(){
        require(!hasToken(),"Token is already defined");
        _;
    }

    modifier onlyIfNftSet(){
        require(hasNft(),"Set nft before doing this action");
        _;
    }

    modifier onlyIfNftNotSet(){
        require(!hasNft(),"NFT is already defined");
        _;
    }

    modifier onlyInvestor(){
        require(investors[msg.sender].registered,"This action is only for investors allowed");
        _;
    }

}