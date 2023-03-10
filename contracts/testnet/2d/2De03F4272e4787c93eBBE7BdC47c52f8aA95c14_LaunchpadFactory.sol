// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}



pragma solidity 0.8.17;
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface ITrustLaunchFees  {
    function getFeeData(uint256 optionId) external view returns (bool active, uint256 fee, address feeReceiver);
    function getFeeDataSE(uint256 optionId, address sender) external view returns (bool active, uint256 fee, address feeReceiver);
}

interface IToken  {
    function deployContract(string memory chosenName,
        string memory chosenSymbol,
        uint8 chosenDecimals,
        uint256 chosenTotalSupply_, address newOwner) external returns (address newContract);
}



abstract contract WalletDetector {
    modifier onlyWallet() {
        require(msg.sender == tx.origin, "Reverting, Method can only be called directly by user.");
        _;
    }
}

interface ILaunchpad  {
    function deployContract(address newOwner, address tokenContract, uint256[] memory numberArray) external returns (address newContract);
}

interface IERC20 {
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
}



contract LaunchpadFactory is WalletDetector, Ownable {

    uint256 public factoryCounter = 0;


    address public _launchpadFactoryContract;
    ILaunchpad public launchpadFactoryContract;


    mapping (uint256 => address) public deployedContracts;
    mapping (address => bool) public wasDeployed;
    
    struct Addresses {
        mapping (uint256 => address) bDeployed;
        uint256 counter;
        address currentAddress;
    }

    mapping (address => Addresses) public deployedAddresses;

    event Deployed(address addr);

    uint256 private MAX_INT = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function setAddress( address newAddr) public onlyOwner {
        _launchpadFactoryContract = newAddr;
        launchpadFactoryContract = ILaunchpad(newAddr);
    }


    function verifyTokenContract(address tc) public view returns (bool, address) {
        if( deployedAddresses[tc].counter == 0) {
            return (true, address(0));
        }
        for( uint256 a = 0; a < deployedAddresses[tc].counter; a++){
            ITrustLaunchLaunchpad tl = ITrustLaunchLaunchpad(deployedAddresses[tc].bDeployed[a]);
            if( !tl.cancelled()){
                return (false, deployedAddresses[tc].bDeployed[a]);
            }


        }
        return (true, address(0));
    }

    function storeNumberArray(address tokenContract, uint256[] memory numberArray) external
    {
        (bool okay, address launchpadAddress) = verifyTokenContract(tokenContract);
        require(!okay , "Unknown Launchpad");
        IERC20 origToken = IERC20(tokenContract);
        uint256 LaunchpadBalance = origToken.balanceOf(launchpadAddress);
        ITrustLaunchLaunchpad tl = ITrustLaunchLaunchpad(launchpadAddress);
        address currentOwner = tl.Owner();
        require(currentOwner == msg.sender, "You are not owner");

        tl.storeNumberArray(numberArray);
        uint256 tokenAmount = tl.getTotalRequiredTokens();
        if( tokenAmount != LaunchpadBalance) {
            if( tokenAmount > LaunchpadBalance) {
                uint256 difference = tokenAmount - LaunchpadBalance;
                origToken.transferFrom(
                    msg.sender,
                    address(this),
                    difference
                );
                uint256 newBalance = origToken.balanceOf(address(this));
                require( newBalance == difference, "Transfer was not successfull");
                origToken.approve(address(this), MAX_INT);
                origToken.transferFrom(
                        address(this),
                        launchpadAddress,
                        difference
                );
                newBalance = origToken.balanceOf(launchpadAddress);
                require( newBalance == tokenAmount, "Transfer 2 was not successfull");
                newBalance = origToken.balanceOf(address(this));
                require( newBalance == 0, "Transfer 3 was not successfull");
            }
            else{
                uint256 difference = LaunchpadBalance - tokenAmount;
                tl.sendBackTokensToFactory(difference);
                uint256 newBalance = origToken.balanceOf(address(this));
                require( newBalance == difference, "Transfer was not successfull");
                origToken.approve(address(this), MAX_INT);
                origToken.transferFrom(
                        address(this),
                        msg.sender,
                        difference
                );
                newBalance = origToken.balanceOf(launchpadAddress);
                require( newBalance == tokenAmount, "Transfer 2 was not successfull");
                newBalance = origToken.balanceOf(address(this));
                require( newBalance == 0, "Transfer 3 was not successfull");
            }
        }
    }




    function deployContract (address tokenContract, uint256[] memory numberArray) public payable onlyWallet {
        if( block.chainid == 97) {
            ITrustLaunchFees tlf = ITrustLaunchFees(0x3EA821C6E0D918e41B873F65F83befb0b66Bb9AA);
            (bool active, uint256 fee, address feeReceiver) = tlf.getFeeDataSE(3, msg.sender);
            if( active) {
                (bool success,) = payable(feeReceiver).call{value: fee}("");
                require(success, "Failed to send!");
            }
        }
        (bool okay,) = verifyTokenContract(tokenContract);
        require(okay, "Cannot deploy same contract");

        address newAddress = launchpadFactoryContract.deployContract(msg.sender, tokenContract, numberArray);
        IERC20 origToken = IERC20(tokenContract);

        ITrustLaunchLaunchpad tl = ITrustLaunchLaunchpad(newAddress);

        uint256 tokenAmount = tl.getTotalRequiredTokens();

        origToken.transferFrom(
                msg.sender,
                address(this),
                tokenAmount
        );
        uint256 newBalance = origToken.balanceOf(address(this));
        require( newBalance == tokenAmount, "Transfer was not successfull");
        origToken.approve(address(this), MAX_INT);
        origToken.transferFrom(
                address(this),
                newAddress,
                tokenAmount
        );
        newBalance = origToken.balanceOf(newAddress);
        require( newBalance == tokenAmount, "Transfer 2 was not successfull");

        newBalance = origToken.balanceOf(address(this));
        require( newBalance == 0, "Transfer 3 was not successfull");

        deployedContracts[factoryCounter] = newAddress; 
        wasDeployed[newAddress] = true;
        factoryCounter++;

        uint256 deployCounter = deployedAddresses[tokenContract].counter;
        deployedAddresses[tokenContract].bDeployed[deployCounter] = newAddress;
        deployedAddresses[tokenContract].counter = deployedAddresses[tokenContract].counter + 1;
        deployedAddresses[tokenContract].currentAddress = newAddress;

        emit Deployed(newAddress);
    }

    function testTransfer(address tokenContract, uint256 tokenAmount) public {
        IERC20 origToken = IERC20(tokenContract);
        origToken.transferFrom(
                msg.sender,
                address(this),
                tokenAmount
        );
        uint256 newBalance = origToken.balanceOf(address(this));
        require( newBalance == tokenAmount, "Transfer was not successfull");
    }
}


interface ITrustLaunchLaunchpad  {
    function cancelled() external view returns (bool active);
    function getTotalRequiredTokens() external view returns (uint256 requiredTokens);
    function storeNumberArray(uint256[] memory numberArray) external;
    function Owner() external view returns (address owner);
    function sendBackTokensToFactory(uint256 tokens) external;
}