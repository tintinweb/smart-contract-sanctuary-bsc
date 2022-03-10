/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

pragma solidity ^0.8.10;

// SPDX-License-Identifier:MIT
interface IBEP20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract DecentAirdrop {
    address public owner;
    IBEP20 public token;

    uint256 public nounce;
    uint256 public currentRound;
    bool public isEnabled;

    mapping(uint256 => mapping(address => bool)) public isClaimed;

    modifier onlyOwner() {
        require(msg.sender == owner, "BEP20: Not an owner");
        _;
    }

    event Claimed(address indexed _user, uint256 indexed _amount);

    constructor(address _owner, address _token) {
        owner = _owner;
        token = IBEP20(_token);
    }

    function ClaimAirDrop(uint256 _amount, uint256 _data) public  {
        require(nounce == _data, "Invalid Data");
        require(isEnabled, "Airdrop disabled");
        require(!isClaimed[currentRound][msg.sender], "Already claimed");
        token.transferFrom(owner, msg.sender, _amount * 10**token.decimals());
        isClaimed[currentRound][msg.sender] = true;
        nounce++;
        emit Claimed(msg.sender, _amount);
    }

    function setCurrentRound(uint256 _value) public onlyOwner {
        currentRound = _value;
    }

    function setAirdropState(bool _state) public onlyOwner {
        isEnabled = _state;
    }

    function changeOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function changeToken(address newToken) public onlyOwner {
        token = IBEP20(newToken);
    }
}