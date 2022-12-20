/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IERC20 {
    function balanceOf(address) external view returns (uint256);

    function transfer(address, uint256) external;

    function transferFrom(
        address,
        address,
        uint256
    ) external;

    function burn(address, uint256) external;
}

contract MTWProVesting {
    event AddVesting(
        uint256 _amount,
        uint256 _begin,
        uint256 _end,
        uint256 _cliff,
        address _recipient
    );

    event ChangeVesting(
        uint256 _amount,
        uint256 _begin,
        uint256 _end,
        uint256 _cliff,
        address _recipient
    );

    event AddVestingByUser(address user);

    event Claim(address _recipient, uint256 _amount);

    event ChangeRecipient(address _recipient, address _newRecipient);

    IERC20 public token;
    address public governance;
    address public pendingGovernance;

    struct AddVestingParams {
        address recipient; // address which should be able to claim tokens
        uint256 amount; // total amount given
        uint256 begin; // start vesting from
        uint256 end; // end vesting on
        uint256 cliff; // how long the user should wait before first claim
    }

    struct Vesting {
        uint256 amount;
        uint256 begin;
        uint256 end;
        uint256 cliff;
        uint256 lastUpdate;
    }

    mapping(address => Vesting) public vestings;

    modifier onlyGovernance() {
        require(msg.sender == governance, "Not allowed");
        _;
    }

    modifier validVesting(
        uint256 _begin,
        uint256 _cliff,
        uint256 _end
    ) {
        require(_begin >= block.timestamp, "Vesting beginning too early, please enter a future date.");
        require(_cliff >= _begin, "Cliff is too early");
        require(_end > _cliff, "End is too early");
        _;
    }

    constructor(address _token, address _governance) {
        token = IERC20(_token);
        governance = _governance;
    }

    function addVesting(AddVestingParams[] calldata params)
        external
        onlyGovernance
    {
        for (uint8 i = 0; i < params.length; i++) {
            addVestingInternal(params[i]);
        }
    }

    /// @notice Add new user to vesting
    function addVestingInternal(AddVestingParams calldata params)
        internal
        validVesting(params.begin, params.cliff, params.end)
    {
        // store vesting details
        Vesting storage vesting = vestings[params.recipient];
        vesting.amount = params.amount;
        vesting.begin = params.begin;
        vesting.end = params.end;
        vesting.cliff = params.cliff;
        vesting.lastUpdate = params.begin;

        emit AddVesting(
            vesting.amount,
            vesting.begin,
            vesting.end,
            vesting.cliff,
            params.recipient
        );
    }

    /// @notice Adds vesting by user after whitelisting
    /// @dev It transferes the number of tokens added by the owner at the time of whitelisting from the user to the contract
    function addVestingByUser() external {
        Vesting storage vesting = vestings[msg.sender];
        require(vesting.amount > 0, "not whitelisted");
        token.transferFrom(msg.sender, address(this), vesting.amount);
        emit AddVestingByUser(msg.sender);
    }

    /// @notice Stops the contract and removes the funds to governance
    /// @param _user Address of the user
    function stop(address _user) external onlyGovernance {
        delete vestings[_user];
    }

    /// @notice Claim the accumulated tokens
    function claim() external {
        Vesting storage vesting = vestings[msg.sender];

        require(block.timestamp >= vesting.cliff, "let the cliff end");

        uint256 rewardsEnd = block.timestamp > vesting.end
            ? vesting.end
            : block.timestamp;

        uint256 numerator = vesting.amount * (rewardsEnd - vesting.lastUpdate);
        uint256 denominator = vesting.end - vesting.begin;

        uint256 amountToRelease = numerator / denominator;
        vesting.lastUpdate = block.timestamp;

        token.transfer(msg.sender, amountToRelease);

        emit Claim(msg.sender, amountToRelease);
    }

    /// @notice Changes recipient
    /// @dev Only the current receipient or governance can change
    /// @param _current current address of recipient
    /// @param _new new address of recipient
    function changeRecipient(address _current, address _new) external {
        require(msg.sender == _current || msg.sender == governance);
        Vesting storage vesting = vestings[_current];
        vestings[_new] = vesting;
        delete vestings[_current];
        emit ChangeRecipient(_current, _new);
    }

    /// @notice Remove any ERC20 from vesting
    /// @param _token Address of the token we want to remve
    /// @param _to Address where the tokens should go
    /// @param _amount The amount of tokens to send
    function remove(
        address _token,
        address _to,
        uint256 _amount
    ) external onlyGovernance {
        IERC20(_token).transfer(_to, _amount);
    }

    /// @notice Change governance
    /// @param _governance new governance
    function changeGovernance(address _governance) external onlyGovernance {
        pendingGovernance = _governance;
    }

    /// @notice Accept governance via 2 step process
    function acceptGovernance() external {
        require(pendingGovernance == msg.sender);
        governance = pendingGovernance;
        pendingGovernance = address(0);
    }

    /// @notice Renounces the ownership of the token contract
    function renounceOwnership() external onlyGovernance {
        governance = address(0);
    }
}