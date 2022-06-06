/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

pragma solidity ^0.8.11;
//SPDX-License-Identifier: MIT
// BABYAPE PRIVATE SALE  


 abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return (msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}
 /*
 * This contract is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;
    mapping (address => bool) internal authorizations;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
     constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        authorizations[_owner] = true;
        emit OwnershipTransferred(address(0), msgSender);
    }

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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    //Modifier to require caller to be authorized
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    //Authorize address.
    function authorize(address account) public onlyOwner {
        authorizations[account] = true;
    }

    // Remove address' authorization.
    function unauthorize(address account) public onlyOwner {
        authorizations[account] = false;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address account) public view returns (bool) {
        return authorizations[account];
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract PresaleBabyApe is Ownable {

    address public tokenAddress = 0x0683f0dD14c098ACEBdfC35144C676814bADA7D9;
    // Nbr tokens per BNB
    uint256 public tokenPrice = 2_000_000 * 10**18; // 2 000 000

    uint256 public tokenDecimals = 18;
    uint256 public nbrTransactions;
    uint256 public nbrBNBsReceived;
    uint256 public nbrTokensSent;
    uint256 public minContribution = 1*10**17; // 0.1 BNB
    uint256 public maxContribution = 10*10**18; // 10 BNB
    uint256 public hardcap = 843*10**18;
    
    uint256 public startAt = 1; 
    uint256 public endAt = 1656180000; // Sat Jun 25 2022 20:00:00 GMT+0200

    mapping(address => uint256) public bnbBalances;
    mapping(address => uint256) public tokenBalances;

    mapping(address => bool) public whitelisted;
    bool public isWhitelistEnabled = true;

    address payable receiverAddress = payable(0x2236e2B167D94b10fc84090bBDC8bfa75a321736);

    event BuyPresale(address indexed sender, uint256 tokensReceived, uint256 bnbSent);
    event Whitelisted(address indexed whitelistedAddress);

   
    /* This function will accept bnb directly sent to the address */
    receive() payable external {
        uint256 amount_ = msg.value;
        address sender_ = _msgSender();
        require(block.timestamp >= startAt, "The presale hasn't started yet");
        require(block.timestamp <= endAt, "The presale is finished");
        // if(isWhitelistEnabled) require(whitelisted[sender_],"You are not whitelisted");
        uint256 nbrTokensToSend = (amount_ * tokenPrice ) / (1*10**18);
        require(bnbBalances[sender_]+amount_ >= minContribution,"You don't reach the minimum contribution. Send more BNBs");
        require(bnbBalances[sender_]+amount_ <= maxContribution, "You have reached the maximum contribution limit or you are trying to send too much BNBs");
        require(nbrBNBsReceived+amount_ <= hardcap, "The hardcap has been reached");
        nbrTransactions+=1;
        nbrBNBsReceived+=amount_;
        nbrTokensSent+=nbrTokensToSend;
        bnbBalances[sender_]+=amount_;
        tokenBalances[sender_]+=nbrTokensToSend;
        IERC20(tokenAddress).transfer(sender_, nbrTokensToSend);
        receiverAddress.transfer(amount_);
        emit BuyPresale(sender_,nbrTokensToSend,amount_);
    }

    function updateTokenDecimals(uint256 newTokenDecimals) public onlyOwner {
        require(tokenDecimals != newTokenDecimals, "The new token decimals is the same as the old one");
        tokenDecimals = newTokenDecimals;
    }

    function updateTokenAddress(address newTokenAddress) public onlyOwner {
        require(tokenAddress != newTokenAddress, "The new token address is the same as the old one");
        tokenAddress = newTokenAddress;
    }

    // Nbr tokens for 1 BNB
    function updateTokenPrice(uint256 newTokenPrice) public onlyOwner {
        require(tokenPrice != newTokenPrice, "The new token price is the same as the old one");
        tokenPrice = newTokenPrice;
    }

    function updateMinContribution(uint256 newMinContribution) public onlyOwner {
        require(minContribution != newMinContribution, "The new min contribution is the same as the old one");
        require(newMinContribution <= maxContribution, "The new min contribution is greater than max contribution");
        minContribution = newMinContribution;
    }

    function updateMaxContribution(uint256 newMaxContribution) public onlyOwner {
        require(maxContribution != newMaxContribution, "The new max contribution is the same as the old one");
        require(newMaxContribution >= minContribution, "The new max contribution is lower than min contribution");
        maxContribution = newMaxContribution;
    }

    function updateHardcap(uint256 newHardcap) public onlyOwner {
        require(hardcap != newHardcap, "The new hardcap is the same as the old one");
        //require(block.timestamp < startAt, "The presale has already begun");
        hardcap = newHardcap;
    }

    function updateStartAt(uint256 newStartAt) public onlyOwner {
        require(startAt != newStartAt, "The new start date is the same as the old one");
        require(block.timestamp < startAt, "The presale has already begun");
        startAt = newStartAt;
    }

    function updateEndAt(uint256 newEndAt) public onlyOwner {
        require(endAt != newEndAt, "The new end date is the same as the old one");
        require(block.timestamp < endAt, "The presale is already finished");
        endAt = newEndAt;
    }

    function updateReceiverAddress(address payable newAddress) external onlyOwner {
        require(receiverAddress != newAddress, "The new address is the same as the old one");
        receiverAddress = newAddress;
    }

    function updateIsWhitelistEnabled(bool isEnabled) external onlyOwner {
        require(isWhitelistEnabled != isEnabled, "The new value is the same as the new one");
        isWhitelistEnabled = isEnabled;
    }

    function addMultipleWhitelists(address[] calldata addresses_) external authorized {
            for(uint32 i = 0 ; i < addresses_.length ; i++) {
            whitelisted[addresses_[i]] = true;
            emit Whitelisted(addresses_[i]);
        }
    }
    function whitelist(address newAddress) external authorized {
        require(!whitelisted[newAddress],"Already whitelisted");
        whitelisted[newAddress] = true;
        emit Whitelisted(newAddress);
    }
    function removeFromWhitelist(address addressToRemove) external authorized {
        require(whitelisted[addressToRemove],"Not whitelisted");
        whitelisted[addressToRemove] = false;
    }

    // Withdraw remaining token after the presale
    function withdrawTokens(address to) public onlyOwner {
        require(IERC20(tokenAddress).transfer(to, IERC20(tokenAddress).balanceOf(address(this))));
    }

    // Withdraw BNBs get during the presale
    function withdrawBNB(address payable to) public onlyOwner {
        to.transfer(address(this).balance);
    }

    // Withdraw lost tokens
    function withdrawTokens(address to, address tokenAddress_) public onlyOwner {
        require(IERC20(tokenAddress_).transfer(to, IERC20(tokenAddress_).balanceOf(address(this))));
    }

    function isWhitelisted(address account) public view returns(bool) {
        return whitelisted[account];
    }

}