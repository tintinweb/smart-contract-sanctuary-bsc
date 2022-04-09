/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

/**
 * Standard SafeMath, stripped down to just add/sub/mul/div
 */
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

contract LuckyBox is Auth {
    using SafeMath for uint256;

    constructor () Auth(msg.sender) {
        OwnerAddress = msg.sender;
    }

    address public OwnerAddress;
    address public FeeAddress = 0xec3c0f514C5A3F71707754602fDD79652d839eE6;
    uint8 constant _decimals = 9;
    uint256 constant _one = 1 * (10 ** _decimals);
    uint256 public LuckyTicket = 0.06 ether;
    uint private LuckyTicketFeePercent = 8;
    uint private LuckyTicketPrizePercent = 12;
    uint256 public LuckyTicketFee = _one.div(100).mul(LuckyTicketFeePercent);
    uint256 public LuckyTicketPrize = LuckyTicket + LuckyTicket.div(100).mul(LuckyTicketPrizePercent);
    uint public LuckyTicketMaxPurchased = 5;
    uint public LuckyTicketTotalPurchased = 0;
    uint public numTotalPlayedRounds = 0;
    address[] private LuckyTicketTicketAddresses;
    bytes private tmpData;

    struct RoundStruct {
        address[] TicketAddresses;
    }

    struct RoundRektStruct {
        uint TicketIndex;
        address TicketAddresses;
    }

    RoundStruct private LuckyTicketRound;
    RoundStruct[] private LuckyTicketRounds;
    RoundRektStruct private LuckyTicketRoundRektStruct;
    RoundRektStruct[] private LuckyTicketRoundRekts;

    function deposit() external payable {
        require(LuckyTicketTotalPurchased < LuckyTicketMaxPurchased, "All tickets for the current round have been purchased... the new round is about to start! Try again in a few seconds!");
        require(msg.sender.balance >= LuckyTicket && msg.value >= LuckyTicket, "You don't have enough BNB! This LuckyTicket is 0.06 BNB!");
        require(msg.value >= LuckyTicket, "This LuckyTicket is 0.06 BNB!");


        (bool isSuccesPaid, bytes memory succesPaidData) = FeeAddress.call{value: LuckyTicket.div(100).mul(LuckyTicketFeePercent), gas: 5000}(
            abi.encodeWithSignature("", "BUY LUCKYTICKET WITH LUCKYBLOCK", 1)
        );

        tmpData = succesPaidData;

        if(isSuccesPaid){
            LuckyTicketTicketAddresses.push(msg.sender);
            LuckyTicketTotalPurchased = LuckyTicketTicketAddresses.length;
        }

        if(LuckyTicketTotalPurchased == LuckyTicketMaxPurchased){
            uint numRoundRektIndex = getRandomNumber(LuckyTicketMaxPurchased);
            LuckyTicketRoundRektStruct.TicketIndex = numRoundRektIndex;
            LuckyTicketRoundRektStruct.TicketAddresses = LuckyTicketTicketAddresses[numRoundRektIndex];
            LuckyTicketRoundRekts.push(LuckyTicketRoundRektStruct);

            LuckyTicketRound.TicketAddresses = LuckyTicketTicketAddresses;
            LuckyTicketRounds.push(LuckyTicketRound);

            delete LuckyTicketTicketAddresses[numRoundRektIndex];

            //send LuckyTicketTicketAddresses Prize
            for(uint i=0; i<LuckyTicketTicketAddresses.length; i++){
                if(0x0000000000000000000000000000000000000000 != LuckyTicketTicketAddresses[i]){
                    (bool isSuccesPaid2, bytes memory succesPaidData2) = LuckyTicketTicketAddresses[i].call{value: LuckyTicketPrize, gas: 5000}(
                        abi.encodeWithSignature("", "BUY LUCKYTICKET WITH LUCKYBLOCK", 1)
                    );

                    if(isSuccesPaid2){
                        tmpData = succesPaidData2;
                    }
                }
            }

            numTotalPlayedRounds = numTotalPlayedRounds+1;
            delete LuckyTicketTicketAddresses;
            LuckyTicketTotalPurchased = 0;
        }
    }

    function getActualRoundTicketAddress(uint index) public view returns (address) {
        return LuckyTicketTicketAddresses[index];
    }

    function getActualRoundTicketsAddress() public view returns (address[] memory) {
        return LuckyTicketTicketAddresses;
    }

    function getAllRounds() public view returns (RoundStruct[] memory) {
        return LuckyTicketRounds;
    }

    function getRoundByIndex(uint index) public view returns (RoundStruct memory) {
        return LuckyTicketRounds[index];
    }

    function getRandomNumber(uint LuckyTicketMaxPurchasedNumber) private view returns (uint) {
        uint randomHash = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, block.number)));
        return randomHash % LuckyTicketMaxPurchasedNumber;
    }

    function getRoundRekt(uint index) public view returns (RoundRektStruct memory) {
        return LuckyTicketRoundRekts[index];
    }

    function rescueToken(address token, address to) external authorized {
        IBEP20(token).transfer(to, IBEP20(token).balanceOf(address(this)));
    }

    function setLuckyTicket(address _FeeAddress, uint256 _LuckyTicket, uint _LuckyTicketFeePercent, uint _LuckyTicketPrizePercent, uint _LuckyTicketMaxPurchased) external authorized {
        FeeAddress = _FeeAddress;
        LuckyTicket = _LuckyTicket;
        LuckyTicketFeePercent = _LuckyTicketFeePercent;
        LuckyTicketPrizePercent = _LuckyTicketPrizePercent;
        LuckyTicketMaxPurchased = _LuckyTicketMaxPurchased;
    }
}