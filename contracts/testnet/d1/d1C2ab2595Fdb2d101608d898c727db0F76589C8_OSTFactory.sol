//SPDX-License-Identifier:UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../contracts/OST.sol";

contract OSTFactory {
    uint256 contractId;
    ///@notice get address by the contract's id
    mapping (uint256=>address) public contracts;
    event ContractCreated(address contr, address asset,address partyA,address partyB,uint256 id);
    function createContract(
        IERC20 asset,
        address partyA,
        address partyB,
        uint256 depTime,
        uint256 signTime
    ) external returns (address) {
        require(address(asset) != address(0), "OST_FACTORY: 'asset' == zero address");
        bytes memory bytecode = abi.encodePacked(type(OST).creationCode, abi.encode(asset,partyA,partyB,depTime,signTime));
        uint256 id = contractId;
        bytes32 salt = keccak256(abi.encodePacked(partyA,partyB,depTime,signTime));
        address ost;
        assembly {
            ost := create2(0, add(bytecode,32), mload(bytecode),salt)
        }
        emit ContractCreated(ost, address(asset), partyA, partyB, id);
        contracts[id] = ost;
        contractId++;

    }
}

//SPDX-License-Identifier:UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title OST
 * @notice smart-contract for ERC20 -> BNB OST deals
 * 
 * ////////////// Conditions of the deal //////////////// @title A title that should describe the contract/interface
 /// @author @cooller458
 /// @notice smart-contract for ERC20 -> ETH OST deals
 /// @dev @omrelibol
    1. There is two parties 'A' and 'B'
    2. Assumed that 'A' deposits pre-aggred (of-Chain) quaintity of ETH waiting to
    receive ERC20 token from 'B'
    3.'B' deposits quantity of needed ERC20 token, pre-agreed off-chain
    4. If both deposits has been received by this contract then parties can sign it
    5. If both deposits has been received by this contract them, abandon the deal and the contract has not yet been signed by both of them,
    the parties of the deal can rescind contact taking initial deposits
    6.if both amounts correspond to the pre-agreed amounts and the parites are satisfied with everthin, the sign a contract when the contract is signet by both,
    the funs can be withdrawn by them
 */

contract OST is ReentrancyGuard {
    //@notice ERC20 asset  for exchange 
    IERC20 private asset;

    /**
     * @notice certain time when:
     * 1. deposits are accepted
     * 2.signing can be done to properly close the deal
     * @notice If time has been expired on any action then deposits returned and contract is destructed by call to function that correspons to the expired action
     */

    struct Periods{
        uint256 depositTime; // depsitTime - time in milliseconds when both parties can make deposits
        uint256 signingTime; //signingTime - time in milliseconds when both parties can sign the contract
    }
    Periods public periods;
    struct Party {
        address addr;
        bool deposited;
        bool signed;
        bool rescinded;
    }
    Party public partyA; // BNB - BEP20
    Party public partyB; // BEP20 - BNB

    mapping (address => Party) public parties;

    event Deposit(address indexed party, uint256 amount);
    event Withdraw(address indexed party, uint256 amount);
    event Sign(address indexed party);
    event Rescind(address indexed party,uint256 amount);

    constructor (
        IERC20 _asset,
        address _partyA,
        address _partyB,
        uint256 _depositTime,
        uint256 _signingTime
    )
    {
        _initContract(
            _asset,
            _partyA,
            _partyB,
            (block.timestamp + _depositTime),
            ((block.timestamp + _depositTime) + _signingTime)
        );
    }
    /**
     * @notice any actions that is changes the states
     * ofthe parties isreviewed by a set of 
     * modifiers linked to each action
     * @notice allowed actions based on the party state:
     * 1. false false false - deposit
     * 2. true ,false,false - sign, rescind
     * 3. true true false - withdraw
     * 4. true true true  - deal has been succesfully cloes - contract desctructed
     */

    modifier depositReview(address party) {
        require(
            parties[msg.sender].addr == party &&
            parties[msg.sender].deposited == false &&
            parties[msg.sender].signed == false &&
            parties[msg.sender].rescinded == false,
            "OST{depositReview}: Deposit condintions hasn't been met"
        );
        if (periods.depositTime < block.timestamp) {
            _returnDeposits();
        }
        _;
    }

    modifier signingReview() {
        require(
            
            parties[msg.sender].addr == partyA.addr || parties[msg.sender].addr == partyB.addr &&
            parties[msg.sender].deposited == true &&
            parties[msg.sender].signed == false &&
            parties[msg.sender].rescinded == false,
            "OST{signingReview}: Signing condintions hasn't been met"

            
        ); 
        ///@notice in case signing time expired
        if (periods.signingTime < block.timestamp) {
            _returnDeposits();
        }
        _;
    }

    modifier rescindReview(address party) {
        require(
            parties[msg.sender].addr == party &&
            parties[msg.sender].deposited == true &&
            parties[msg.sender].signed == false &&
            parties[msg.sender].rescinded == false,
            "OST{rescindReview}: Rescind condintions hasn't been met"
        );
        _;
    }
    modifier exchangeReview(address party) {
        require(
            parties[msg.sender].addr == party &&
            parties[msg.sender].deposited == true &&
            parties[msg.sender].signed == true &&
            parties[msg.sender].rescinded == false,
            "OST{exchangeReview}: Withdraw condintions hasn't been met"
        );
        _;
    }

    /**
     * Getters*
     */

    /**
     * @notice parties can check if needed amount of 'asset' is on the contract's balance
     */

    function getAssetBalance() external view returns(uint256) {
        return asset.balanceOf(address(this));
    }
    ///@notice parties can chech if needed amount of BNB is on the contract's balance
    function getBnbBalance()external view returns(uint256) {
        return address(this).balance;
    }
    /**
     * ""
     *      ***************
     *      ****DEPOSIT****
     *      ***************
     */

    ///@notice  only 'partyA' can deposit BNB
    function depositBnb() external payable depositReview(partyA.addr) nonReentrant {
        ///@notice no need for deals with 0 amount pre-agreed
        require(msg.value > 0, "OST{depositBnb}: BNB amount should be 0");
        _updatePartyState(msg.sender, true , false , false);

        emit Deposit(msg.sender,msg.value);
    }

    function depositAsset(uint256 amount) external depositReview(partyB.addr) nonReentrant {
        require(amount > 0 , "OST{depositAsset}: 'asset' amount should be >0");
        ///@notice approve amount first
        asset.transferFrom(msg.sender,address(this), amount);
        _updatePartyState(msg.sender,true,false,false);

        emit Deposit(msg.sender,amount);
    }

    /**
     *  ************
     *  ** SIGNING **
     *  ************
     */
    ///@notice accept that proper amount of funds has been sent by a counterparty
    ///@notice once contract is signet this action can't be canceled
    function signContract() external signingReview nonReentrant {
        _updatePartyState(msg.sender,true,true,false);

        emit Sign(msg.sender);
    }
    /*
        **************
        ** EXCHANGE **
        **************
    */
    ///@notice withdrawal of `asset` allowed only to `A`
    function withdrawAsset() external exchangeReview(partyA.addr) {
        uint256 amount = asset.balanceOf(address(this));
        asset.transfer(msg.sender, amount);
        _updatePartyState(msg.sender, true, true, true);

        emit Withdraw(msg.sender, amount);

        if (
            partyB.deposited == true &&
            partyB.signed == true &&
            partyB.rescinded == true
        ) {
            selfdestruct(payable(address(0)));
        }
    }
    ///@notice withdrawal of ether allowed only to 'B'
    function withdrawBnb() external exchangeReview(partyB.addr) {
        uint256 amount = address(this).balance;

        /**
         * @notice if 'A' already withdraw his tokens
         * then BNB ether would be sent to 'B'usingg 'selfdestruct'
         */

        if(
            partyA.deposited == true &&
            partyA.signed == true &&
            partyA.rescinded == true
        ) {
            emit Withdraw(msg.sender,amount);
            selfdestruct(payable(msg.sender));
        } else {
            payable(msg.sender).transfer(amount);
            _updatePartyState(msg.sender,true,true,true);
            emit Withdraw(msg.sender,amount);
        }
    }

        /*
        **********************
        ** RESCIND CONTRACT **
        **********************
    */
    ///@notice rescind conrtact and return funds

    function rescindContractA() external rescindReview(partyA.addr) nonReentrant {
        _returnDeposits();
    }

    ///@notice rescind contract and return funds
    function rescindContractB() external rescindReview(partyB.addr) nonReentrant {
        _returnDeposits();
    }
      /*
        ***************
        ** INTERNALS **
        ***************
    */
    ///@notice set state variables to values defined in a constructor
       function _initContract(
        IERC20 _asset,
        address _partyA,
        address _partyB,
        uint256 _depositTime,
        uint256 _rescindTime
    ) internal {
        asset = _asset;
        partyA = Party(_partyA, false, false, false);
        partyB = Party(_partyB, false, false, false);
        parties[_partyA] = partyA;
        parties[_partyB] = partyB;
        periods = Periods(_depositTime, _rescindTime);
    }
    
    ///@notice use in deposits and signings
    function _updatePartyState(address _party, bool _deposited, bool _signed, bool _rescinded) internal {
        parties[_party].deposited = _deposited;
        parties[_party].signed = _signed; 
        parties[_party].rescinded = _rescinded;
    }

    ///@notice return deposits and destruct contract
    function _returnDeposits() internal {
        ///@notice balance can be 0 if deposit hasn't been made
        asset.transfer(partyB.addr, asset.balanceOf(address(this)));
        ///@notice selfdestruct contract and return ether to `A`
        selfdestruct(payable(partyA.addr));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}