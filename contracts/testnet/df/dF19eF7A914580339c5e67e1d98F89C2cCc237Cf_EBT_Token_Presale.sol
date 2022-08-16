/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}


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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract EBT_Token_Presale is Ownable {

    IERC20 EBTToken;

    AggregatorV3Interface internal priceFeed;

    uint256 public MinUSD = 40;

    uint256 private _tokenDecimal = 18;
    uint256 private _PresaleToken = 100_000_000 * (10 ** _tokenDecimal);
    uint256 public _SoldOut;
    bool public paused;

    uint256 PhaseOne = 6120000000000; //(100M to 75M) 1 EBT = 0.00000612 BNB
    uint256 PhaseTwo = 7344000000000; //(75M to 25M) 1 EBT = 0.000007344 BNB
    uint256 PhaseThree = 8568000000000; //(<25M) 1 EBT = 0.000008568 BNB

    uint256 PhaseOneLimit = 75_000_000 * (10 ** _tokenDecimal);
    uint256 PhaseTwoLimit = 25_000_000 * (10 ** _tokenDecimal);

    constructor(address _token) {
        EBTToken = IERC20(_token);
        //priceFeed = AggregatorV3Interface(0x87Ea38c9F24264Ec1Fff41B04ec94a97Caf99941);  //Mainnet
        priceFeed = AggregatorV3Interface(0x0630521aC362bc7A19a4eE44b57cE72Ea34AD01c);   //Testnet
    }

    uint public a;

    function joinPresale(address _ref) public payable {

        uint contractBalance = getBalance();
        uint256 USDData = getMinBuyD();
        bool transferRef;
        uint PhaseChecker;
        uint EstimatedToken;

        require(contractBalance != 0,"Contract Balance is Low!!");
        require(!paused,"Presale is Currently Paused!!");

        require(msg.value >= USDData,"Error: Cannot Buy less than Set Limit!!");

        //  -- Phase Detection --

        if (contractBalance > PhaseOneLimit) {
            require(msg.value >= PhaseOne,"-> 1 EBT = 0.00000612 BNB!!");
            PhaseChecker = 1;
        }
        else if (contractBalance > PhaseTwoLimit) {
            require(msg.value >= PhaseTwo,"-> 1 EBT = 0.000007344 BNB!!");
            PhaseChecker = 2;
        }
        else {
            require(msg.value > PhaseThree,"-> 1 EBT = 0.000008568 BNB!!");
            PhaseChecker = 3;
        }

        //  -- Referral --

        if(_ref == msg.sender || _ref == address(0x0)) {
            transferRef = false;
        }
        else {
            if(EBTToken.balanceOf(_ref) > 0) {
                transferRef = true;
            }
            else {
                transferRef = false;
            }
        }

        uint256 value = msg.value;

        if(transferRef) {
            uint TenPercent = value * (10) / 100;
            payable(_ref).transfer(TenPercent);
        }

        if(PhaseChecker == 1) {
            EstimatedToken = value * (10 ** _tokenDecimal) / PhaseOne;
        }

        if(PhaseChecker == 2) {
            EstimatedToken = value * (10 ** _tokenDecimal) / PhaseTwo;
        }

        if(PhaseChecker == 3) {
            EstimatedToken = value * (10 ** _tokenDecimal) / PhaseThree;
        }

        if(EstimatedToken > 0) {
            EBTToken.transfer(msg.sender,EstimatedToken);
            _SoldOut += EstimatedToken;
        }
        else {
            revert("Error: Something went wrong!!");
        }
    }

    function setPause(bool _status) public onlyOwner {
        paused = _status;
    }

    function getBalance() public view returns (uint) {
        return EBTToken.balanceOf(address(this));
    }

    function withdrawFunds() public onlyOwner {
        (bool os,) = payable(msg.sender).call{value: address(this).balance}("");
        require(os,"Transaction Failed!!");
    }
	
	function rescueToken() public onlyOwner {
		EBTToken.transfer(msg.sender,EBTToken.balanceOf(address(this)));
	}

    function getLatestPrice() public view returns (int) {
        (
            ,int price,,,
        ) = priceFeed.latestRoundData();
        return price;
    }

    function getRunningPhase() public view returns (uint) {
        
        uint contractBalance = getBalance();

        if (contractBalance > PhaseOneLimit) {
            return 1;
        }
        else if (contractBalance > PhaseTwoLimit) {
            return 2;
        }
        else {
            return 3;
        }
    }

    function getMinBuyD() public view returns (uint) {
        unchecked {
            return MinUSD * uint(getLatestPrice());
        }
    }

    function setUsd(uint _value) public onlyOwner {
        MinUSD = _value;
    }


}