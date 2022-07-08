/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

pragma solidity >=0.8.4;

contract Auction {
    // static
    address public owner;
    uint public bidIncrement;
    uint public startBlock;
    uint public endBlock;
    string public name;
    mapping (address => bool) public allowedBidder;

    // state
    bool public canceled;
    address public highestBidder;
    mapping(address => uint256) public fundsByBidder;
    bool public ownerHasWithdrawn;

    event LogBid(address bidder, uint bid, address highestBidder, uint highestBid);
    event LogWithdrawal(address withdrawer, address withdrawalAccount, uint amount);
    event LogCanceled();

    constructor(address _owner,
                uint _startPrice,
                uint _startBlock,
                uint _endBlock,
                string memory _name,
                address[] memory _addresses) {
        require(_startBlock + 1 < _endBlock);
        require(_startBlock > block.number);
        require(_owner != address(0));

        owner = _owner;
        // at the very beginning it's the base price, every bid will increase 5%
        bidIncrement = 0;
        fundsByBidder[highestBidder] = _startPrice;
        startBlock = _startBlock;
        endBlock = _endBlock;
        name = _name;
        for (uint256 i=0; i<_addresses.length; i++) {
            allowedBidder[_addresses[i]] = true;
        }
    }

    function getHighestBid()
        public
        view
        returns (uint)
    {
        return fundsByBidder[highestBidder];
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function placeBid()
        payable
        onlyAfterStart
        onlyBeforeEnd
        onlyNotCanceled
        onlyNotOwner
        onlyAllowedBidder
        public returns (bool success)
    {
        // reject payments of 0 ETH
        require (msg.value > 0, "can't bid with 0 value") ;
        uint newBid = fundsByBidder[msg.sender] + msg.value;
        uint highestBid = fundsByBidder[highestBidder];
        require (newBid > (highestBid + bidIncrement), "must be larger than current best bid");
        fundsByBidder[msg.sender] = newBid;
        highestBid = newBid;
        highestBidder = msg.sender;
        bidIncrement = max((highestBid * 105 / 100) - highestBid, bidIncrement);

        emit LogBid(msg.sender, newBid, highestBidder, highestBid);
        return true;
    }

    function min(uint a, uint b)
        private
        pure 
        returns (uint)
    {
        if (a < b) return a;
        return b;
    }

    function cancelAuction()
        onlyOwner
        onlyBeforeEnd
        onlyNotCanceled
        public returns (bool success)
    {
        canceled = true;
        emit LogCanceled();
        return true;
    }

    function withdraw()
        onlyEndedOrCanceled
        public returns (bool success)
    {
        address withdrawalAccount;
        uint withdrawalAmount;

        if (canceled) {
            // if the auction was canceled, everyone should simply be allowed to withdraw their funds
            withdrawalAccount = msg.sender;
            withdrawalAmount = fundsByBidder[withdrawalAccount];

        } else {
            // the auction finished without being canceled
            require(msg.sender != highestBidder, "winner can not withdraw!");
            if (msg.sender == owner) {
                // the auction's owner should be allowed to withdraw the highestBindingBid
                withdrawalAccount = highestBidder;
                withdrawalAmount = fundsByBidder[highestBidder];
                ownerHasWithdrawn = true;
            } else {
                // anyone who participated but did not win the auction should be allowed to withdraw
                // the full amount of their funds
                withdrawalAccount = msg.sender;
                withdrawalAmount = fundsByBidder[withdrawalAccount];
            }
        }

        require (withdrawalAmount > 0, "amount must be larger than 0");

        fundsByBidder[withdrawalAccount] -= withdrawalAmount;

        // send the funds
	    payable(msg.sender).transfer(withdrawalAmount);

        emit LogWithdrawal(msg.sender, withdrawalAccount, withdrawalAmount);

        return true;
    }

    modifier onlyOwner {
        require (msg.sender == owner, "must be owner!");
        _;
    }

    modifier onlyNotOwner {
        require (msg.sender != owner, "must not be owner!");
        _;
    }

    modifier onlyAfterStart {
        require (block.number > startBlock, "only after start!") ;
        _;
    }

    modifier onlyBeforeEnd {
        require (block.number < endBlock, "already end!") ;
        _;
    }

    modifier onlyNotCanceled {
        require (!canceled, "only not cancelled");
        _;
    }

    modifier onlyEndedOrCanceled {
        require(block.number > endBlock || canceled, "must be ended or cancelled!") ;
        _;
    }

    modifier onlyAllowedBidder {
        require (allowedBidder[msg.sender], "you are not allowed to bid!");
        _;
    }
}

contract Ownable 
{    
  // Variable that maintains 
  // owner address
  address private _owner;
  
  // Sets the original owner of 
  // contract when it is deployed
  constructor()
  {
    _owner = msg.sender;
  }
  
  // Publicly exposes who is the
  // owner of this contract
  function owner() public view returns(address) 
  {
    return _owner;
  }
  
  // onlyOwner modifier that validates only 
  // if caller of function is contract owner, 
  // otherwise not
  modifier onlyOwner() 
  {
    require(isOwner(),
    "Function accessible only by the owner !!");
    _;
  }
  
  // function for owners to verify their ownership. 
  // Returns true for owners otherwise false
  function isOwner() public view returns(bool) 
  {
    return msg.sender == _owner;
  }
}

contract AuctionFactory is Ownable {
    address[] public auctions;
    mapping(string => address) public auctionDics;

    event AuctionCreated(address auctionContract, address owner, uint numAuctions, address[] allAuctions);

    constructor() {
    }

    function createAuction(uint startPrices,
                           uint startBlock,
                           uint endBlock,
                           string memory name,
                           address[] memory _addresses) public onlyOwner {
        Auction newAuction = new Auction(msg.sender, startPrices, startBlock, endBlock, name, _addresses);
        auctions.push(address(newAuction));
        auctionDics[name] = address(newAuction);
        emit AuctionCreated(address(newAuction), msg.sender, auctions.length, auctions);
    }

    function allAuctions() public view returns (address[] memory ) {
        return auctions;
    }

    function getAuction(string memory name) public view returns(address) {
        return auctionDics[name];
    }
}