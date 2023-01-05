// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "IERC20.sol";

contract StknICO {
    //Administration Details
    address public admin;
    address payable public ICOWallet;

    //Token
    IERC20 public token;

    //ICO Details
    uint public tokenPrice = 0.1 ether;
    uint public hardCap = 500 ether;
    uint public raisedAmount;
    uint public minInvestment = 0.5 ether;
    uint public maxInvestment = 100 ether;
    uint public icoStartTime;
    uint public icoEndTime;

    //Investor
    mapping(address => uint) public investedAmountOf;

    //ICO State
    enum State {
        BEFORE,
        RUNNING,
        END,
        HALTED
    }
    State public ICOState;

    //Events
    event Invest(
        address indexed from,
        address indexed to,
        uint value,
        uint tokens
    );
    event TokenBurn(address to, uint amount, uint time);

    //Initialize Variables
    constructor(address payable _icoWallet, address _token) {
        admin = msg.sender;
        ICOWallet = _icoWallet;
        token = IERC20(_token);
    }

    //Access Control
    modifier onlyAdmin() {
        require(msg.sender == admin, "Admin Only function");
        _;
    }

    //Receive Ether Directly
    receive() external payable {
        invest();
    }

    fallback() external payable {
        invest();
    }

    /* Functions */

    //Get ICO State
    function getICOState() external view returns (string memory) {
        if (ICOState == State.BEFORE) {
            return "Not Started";
        } else if (ICOState == State.RUNNING) {
            return "Running";
        } else if (ICOState == State.END) {
            return "End";
        } else {
            return "Halted";
        }
    }

    /* Admin Functions */

    //Start, Halt and End ICO
    function startICO() external onlyAdmin {
        require(ICOState == State.BEFORE, "ICO isn't in before state");

        icoStartTime = block.timestamp;
        icoEndTime = icoStartTime + (86400 * 365);
        ICOState = State.RUNNING;
    }

    function haltICO() external onlyAdmin {
        require(ICOState == State.RUNNING, "ICO isn't running yet");
        ICOState = State.HALTED;
    }

    function resumeICO() external onlyAdmin {
        require(ICOState == State.HALTED, "ICO State isn't halted yet");
        ICOState = State.RUNNING;
    }

    //Change ICO Wallet
    function changeICOWallet(address payable _newICOWallet) external onlyAdmin {
        ICOWallet = _newICOWallet;
    }

    //Change Admin
    function changeAdmin(address _newAdmin) external onlyAdmin {
        admin = _newAdmin;
    }

    /* User Function */
    
    //Invest
    function invest() public payable returns (bool) {
        require(ICOState == State.RUNNING, "ICO isn't running");
        require(
            msg.value >= minInvestment && msg.value <= maxInvestment,
            "Check Min and Max Investment"
        );
        require(
            investedAmountOf[msg.sender] + msg.value <= maxInvestment,
            "Investor reached maximum Investment Amount"
        );

        require(
            raisedAmount + msg.value <= hardCap,
            "Send within hardcap range"
        );
        require(
            block.timestamp <= icoEndTime,
            "ICO already Reached Maximum time limit"
        );

        raisedAmount += msg.value;
        investedAmountOf[msg.sender] += msg.value;

        (bool transferSuccess, ) = ICOWallet.call{value: msg.value}("");
        require(transferSuccess, "Failed to Invest");

        uint tokens = (msg.value / tokenPrice) * 1e18;
        bool saleSuccess = token.transfer(msg.sender, tokens);
        require(saleSuccess, "Failed to Invest");

        emit Invest(address(this), msg.sender, msg.value, tokens);
        return true;
    }

    //Burn Tokens
    function burn() external returns (bool) {
        require(ICOState == State.END, "ICO isn't over yet");

        uint remainingTokens = token.balanceOf(address(this));
        bool success = token.transfer(address(0), remainingTokens);
        require(success, "Failed to burn remaining tokens");

        emit TokenBurn(address(0), remainingTokens, block.timestamp);
        return true;
    }

    //End ICO After reaching Hardcap or ICO Timelimit
    function endIco() public {
        require(ICOState == State.RUNNING, "ICO Should be in Running State");
        require(
            block.timestamp > icoEndTime || raisedAmount >= hardCap,
            "ICO Hardcap or timelimit not reached"
        );
        ICOState = State.END;
    }

    //Check ICO Contract Token Balance
    function getICOTokenBalance() external view returns (uint) {
        return token.balanceOf(address(this));
    }

    //Check ICO Contract Investor Token Balance
    function investorBalanceOf(address _investor) external view returns (uint) {
        return token.balanceOf(_investor);
    }
}