// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./IERC20.sol";
import "./Ownable.sol";

contract BIFInvestmentContract is Ownable {
    struct Investment {
        address investor;
        uint256 amount;
        uint8 planId; // 0 for UltraSafe, 1 for MidCap, 2 for SmallCap
        uint256 startTimestamp;
        uint256 lockDuration;
        bool withdrawn;
        uint256 totalProfit;
    }

    uint256 launchTime;

    IERC20 public usdtToken;
    IERC20 public busdToken;
    address public treasury;

    mapping(address => mapping(uint256 => Investment)) public investments;
    mapping(address => uint256) public investmentCount;
    mapping(address => uint256) public totalInvestedAmount;
    mapping(address => bool) public earlyInvestors;
    mapping(address => bool) public frozenAccounts;

    event Invested(
        address indexed investor,
        uint256 investmentId,
        uint256 amount,
        uint256 lockterm
    );
    event Withdrawn(
        address indexed investor,
        uint256 investmentId,
        uint256 amount
    );
    event Compounded(uint256 investmentId, uint256 amount, uint256 newLockTerm);

    event Whitelisted(address[] investors);
    event AccountFrozen(address investor, string reason);
    event ETHCollected(address collector, uint256 amount);
    event IERC20TokenWithdrawn(address collector, uint256 amount);
    event FundsWithdrawn(address treasury, uint256 usdtAmount, uint256 busdAmount, string reason);

    constructor(
        address _usdtTokenAddress,
        address _busdTokenAddress,
        address _treasury
    ) {
        require(
            _usdtTokenAddress != address(0) && _treasury != address(0),
            "Can't set to zero address"
        );
        usdtToken = IERC20(_usdtTokenAddress);
        busdToken = IERC20(_busdTokenAddress);
        treasury = _treasury;
        launchTime = block.timestamp;
    }

    function getInvestmentIds(address wallet)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory investmentIds = new uint256[](investmentCount[wallet]);

        for (uint256 i = 1; i <= investmentCount[wallet]; i++) {
            investmentIds[i - 1] = i;
        }

        return investmentIds;
    }

    function invest(
        IERC20 _tokenAddress,
        uint256 _amount,
        uint8 _planId,
        uint256 _lockduration
    ) external {
        require(_amount > 100 * 1e18, "Amount must be greater than $100");
        require(
            _tokenAddress == usdtToken || _tokenAddress == busdToken,
            "Use either USDT or BUSD only!"
        );

        if (block.timestamp <= launchTime + 89 days) {
            require(
                earlyInvestors[msg.sender],
                "Only whitelisted addresses can participate in first 90 days!"
            );
        }

        if (_planId > 0) {
            require(
                totalInvestedAmount[msg.sender] >= 1000 * 1e18,
                "Minimum $1000 should be invested in UltraSafe fund!"
            );
        }

        uint256 investmentId = investmentCount[msg.sender] + 1;

        _tokenAddress.transferFrom(msg.sender, address(this), _amount);

        uint256 lockterm = _lockduration * 1 days;

        investments[msg.sender][investmentId] = Investment({
            // uniqueId: _uniqueId,
            investor: msg.sender,
            amount: _amount,
            planId: _planId,
            startTimestamp: block.timestamp,
            lockDuration: lockterm,
            withdrawn: false,
            totalProfit: 0
        });

        investmentCount[msg.sender]++;
        totalInvestedAmount[msg.sender] += _amount;

        emit Invested(msg.sender, investmentId, _amount, lockterm);
    }

    function withdrawInvestment(
        uint256 _investmentId,
        uint256 _amount,
        uint256 nonce,
        bytes memory _signature
    ) external {
        Investment storage investment = investments[msg.sender][_investmentId];

        require(
            investment.investor == msg.sender,
            "Only the investor can withdraw their investment"
        );
        require(!investment.withdrawn, "Investment has already been withdrawn");
        require(
            !frozenAccounts[msg.sender],
            "This account has been frozen on account of hack!"
        );

        bytes32 message = prefixed(
            keccak256(abi.encodePacked(msg.sender, _amount, nonce, this))
        );

        require(
            recoverSigner(message, _signature) == msg.sender,
            "Invalid signature"
        );

        if (
            block.timestamp <
            investment.startTimestamp + investment.lockDuration
        ) {
            uint256 earlyWithdrawalPenalty = investment.amount / 100;
            uint256 withdrawableAmnt = investment.amount -
                earlyWithdrawalPenalty;

            require(
                usdtToken.balanceOf(address(this)) >= withdrawableAmnt,
                "Not enough balance in the contract"
            );

            usdtToken.transfer(msg.sender, withdrawableAmnt);
        } else {
            uint256 profitEarned = _amount - investment.amount;
            investment.totalProfit += profitEarned;

            require(
                usdtToken.balanceOf(address(this)) >= _amount,
                "Not enough balance in the contract"
            );

            usdtToken.transfer(msg.sender, _amount);
        }

        investment.withdrawn = true;

        emit Withdrawn(msg.sender, _investmentId, _amount);
    }

    function _compound(
        uint256 _investmentId,
        uint256 _amount,
        uint256 _lockduration,
        uint256 nonce,
        bytes memory _signature
    ) external {
        Investment storage investment = investments[msg.sender][_investmentId];

        require(
            investment.investor == msg.sender,
            "Only the investor can withdraw their investment"
        );
        require(!investment.withdrawn, "Investment has already been withdrawn");
        require(
            !frozenAccounts[msg.sender],
            "This account has been frozen on account of hack!"
        );
        require(
            block.timestamp >=
                investment.startTimestamp + investment.lockDuration,
            "Investment is locked!"
        );

        bytes32 message = prefixed(
            keccak256(abi.encodePacked(msg.sender, _amount, nonce, this))
        );

        require(
            recoverSigner(message, _signature) == msg.sender,
            "Invalid signature"
        );

        uint256 newLockTerm = _lockduration * 1 days;

        investment.amount += _amount;
        investment.lockDuration = newLockTerm;

        emit Compounded(_investmentId, _amount, newLockTerm);
    }

    function prefixed(bytes32 _hash) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
            );
    }

    function recoverSigner(bytes32 _message, bytes memory _signature)
        internal
        pure
        returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(_signature);

        return ecrecover(_message, v, r, s);
    }

    function splitSignature(bytes memory _signature)
        internal
        pure
        returns (
            uint8,
            bytes32,
            bytes32
        )
    {
        require(_signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }

        return (v, r, s);
    }

    // Admin priveledges

    function _addEarlyInvestors(address[] calldata investors, bool state)
        external
        onlyOwner
    {
        require(block.timestamp <= launchTime + 89 days, "Phase I has ended!");
        for (uint256 i = 0; i < investors.length; i++) {
            require(investors[i] != address(0));
            earlyInvestors[investors[i]] = state;
        }
        emit Whitelisted(investors);
    }

    function freezeAccount(
        address _investor,
        string memory _reason,
        uint256 nonce,
        bytes memory _signature
    ) external onlyOwner {
        require(!frozenAccounts[_investor], "Account is already frozen!");

        bytes32 message = prefixed(
            keccak256(abi.encodePacked(msg.sender, _reason, nonce, this))
        );

        require(
            recoverSigner(message, _signature) == msg.sender,
            "Invalid signature"
        );

        frozenAccounts[_investor] = true;

        emit AccountFrozen(_investor, _reason);
    }

    function collectETH() external onlyOwner {
        uint256 fundsToSend = address(this).balance;
        bool sent = payable(treasury).send(fundsToSend);
        require(sent, "Failed to send Ether");

        emit ETHCollected(treasury, fundsToSend);
    }

    function withdrawOtherTokens(address _token) external onlyOwner {
        require(_token != address(0), "can't withdraw zero token");
        require(
            IERC20(_token) != usdtToken && IERC20(_token) != busdToken,
            "Use collectUSDT method!"
        );
        uint256 fundsToSend;

        fundsToSend = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(msg.sender, fundsToSend);

        emit IERC20TokenWithdrawn(msg.sender, fundsToSend);
    }

    function collectFunds(string memory _reason) external onlyOwner {
        uint256 usdtToSend = usdtToken.balanceOf(address(this));
        uint256 busdToSend = busdToken.balanceOf(address(this));

        if (usdtToSend > 0 || busdToSend > 0) {
            usdtToken.transfer(treasury, usdtToSend);
            busdToken.transfer(treasury, busdToSend);
        }

        emit FundsWithdrawn(treasury, usdtToSend, busdToSend, _reason);
    }
}