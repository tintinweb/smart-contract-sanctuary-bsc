/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal pure virtual returns (bytes calldata) {
        return msg.data;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

interface IERC20 {
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

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) +
            (value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }
    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) -
            (value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

contract Binary_Land is Context {
    using SafeERC20 for IERC20;

    struct Node {
        uint128 NumberOfChildNodeOnLeft;
        uint128 NumberOfChildNodeOnRight;
        uint256 NumberOfBalancedCalculated;
        uint256 TotalUserRewarded;
        uint256 NumberOfNewBalanced;
        uint256 RewardAmountNotReleased;
        address LeftNode;
        address RightNode;
        address UplineAddress;
        int8 DirectionOfCurrentNodeInUplineNode; // left: -1, right: 1 
        bool Status;
    }
    
    mapping(address => Node) private _users;
    mapping(address => bool) private _oldUsers;
    address[] private _usersAddresses;

    uint256 private lastRun;
    address private owner;
    IERC20 private tetherToken;
    uint256 private registrationFee;
    uint256 private numberOfRegisteredUsersIn_24Hours;
    uint256 private totalBalance;
    uint256 private allPayments;
    uint256 private numberOfNewBalanceIn_24Hours;
    uint256 private constMaxBalanceForCalculatedReward;
    
    event UserRegistered(address indexed upLine, address indexed newUser);


    constructor(address headOfUpline, address _tetherToken) {
        owner = _msgSender();
        registrationFee = 70 ether;

        tetherToken = IERC20(_tetherToken);
        lastRun = block.timestamp;
        numberOfRegisteredUsersIn_24Hours = 0;
        numberOfNewBalanceIn_24Hours = 0;
        constMaxBalanceForCalculatedReward = 8  
        ;
        
        _users[headOfUpline] = Node({
            NumberOfChildNodeOnLeft: 0,
            NumberOfChildNodeOnRight: 0,
            NumberOfBalancedCalculated : 0,
            TotalUserRewarded: 0,
            NumberOfNewBalanced: 0,
            RewardAmountNotReleased: 0,
            LeftNode: address(0),
            RightNode: address(0),
            UplineAddress: address(0),
            DirectionOfCurrentNodeInUplineNode: 1,
            Status: true
        });

        _usersAddresses.push(headOfUpline);
    }


    modifier onlyOwner() {
        require(_msgSender() == owner, "Just Owner Can Run This Order!");
        _;
    }

    function Calculating_Rewards_In_24_Hours() public {

        require(
            block.timestamp > lastRun + 1 days,
            "The Calculating_Node_Rewards_In_24_Hours Time Has Not Come"
        );


        uint256 rewardPerBalanced = Today_Reward_Per_Balance();
        uint256 userReward;

        for (uint256 i=0; i < _usersAddresses.length; i = i+1) {

            if (_users[_usersAddresses[i]].NumberOfNewBalanced > constMaxBalanceForCalculatedReward ) {
                userReward = rewardPerBalanced * constMaxBalanceForCalculatedReward;

            } else {
                userReward = rewardPerBalanced * _users[_usersAddresses[i]].NumberOfNewBalanced; 

            }

            _users[_usersAddresses[i]].NumberOfBalancedCalculated += _users[_usersAddresses[i]].NumberOfNewBalanced;
            _users[_usersAddresses[i]].NumberOfNewBalanced = 0;

            if (userReward > 0) {
                _users[_usersAddresses[i]].RewardAmountNotReleased += userReward;
            }

        }

        lastRun = block.timestamp;
        numberOfRegisteredUsersIn_24Hours = 0;
        numberOfNewBalanceIn_24Hours = 0;

    }

    function B_Withdraw() public {

        require(_users[_msgSender()].RewardAmountNotReleased > 0, "You have not received any award yet");
        
        uint256 reward;
        reward = _users[_msgSender()].RewardAmountNotReleased;
        _users[_msgSender()].TotalUserRewarded += reward;
        _users[_msgSender()].RewardAmountNotReleased = 0;
        tetherToken.safeTransfer(_msgSender(), reward);
        
    }

    function Emergency_72() onlyOwner public {
        require(
            block.timestamp > lastRun + 3 days,
            "The Emergency_72 Time Has Not Come"
        );
        require(tetherToken.balanceOf(address(this)) > 0 , "contract not have balance");

        tetherToken.safeTransfer(
            owner,
            tetherToken.balanceOf(address(this))
        );
    }

    function A_Register(address uplineAddress) public {
        require(
            _users[uplineAddress].LeftNode == address(0) || _users[uplineAddress].RightNode == address(0) ,
            "This address have two directs and could not accept new members!"
        );
        require(
            _msgSender() != uplineAddress,
            "You can not enter your own address!"
        );

        require(_users[_msgSender()].Status == false, "This address is already registered!");
        require(_users[uplineAddress].Status == true, "This Upline address is Not Exist!");

        uint256 NumberOfCurrentBalanced;
        uint256 NumberOfNewBalanced;

        address temp_UplineAddress;
        address temp_CurrentAddress;
        int8 temp_DirectionOfCurrentNodeInUplineNode;
        

        if (_oldUsers[_msgSender()] == false) {
            tetherToken.safeTransferFrom(
                _msgSender(),
                address(this),
                registrationFee
            );       
        }

        if (_users[uplineAddress].RightNode == address(0)) {

            _users[uplineAddress].RightNode = _msgSender();
            temp_DirectionOfCurrentNodeInUplineNode = 1;
        
        } else {
        
            _users[uplineAddress].LeftNode = _msgSender();
            temp_DirectionOfCurrentNodeInUplineNode = -1;
        
        }
        
        _users[_msgSender()] = Node({
            NumberOfChildNodeOnLeft: 0,
            NumberOfChildNodeOnRight: 0,
            NumberOfBalancedCalculated : 0,
            TotalUserRewarded: 0,
            NumberOfNewBalanced : 0,
            RewardAmountNotReleased: 0,
            LeftNode: address(0),
            RightNode: address(0),
            UplineAddress: uplineAddress,
            DirectionOfCurrentNodeInUplineNode: temp_DirectionOfCurrentNodeInUplineNode,
            Status: true
        });

        temp_UplineAddress = uplineAddress;
        temp_CurrentAddress = _msgSender();

        if (_oldUsers[temp_CurrentAddress] == false) {
            while (true) {
                
                if (_users[temp_UplineAddress].Status == false) {
                    break;
                }

                if (temp_DirectionOfCurrentNodeInUplineNode == 1) {
                    _users[temp_UplineAddress].NumberOfChildNodeOnRight += 1;

                } else {
                    _users[temp_UplineAddress].NumberOfChildNodeOnLeft += 1;

                }

                NumberOfCurrentBalanced = _users[temp_UplineAddress].NumberOfChildNodeOnLeft;
                
                if ( _users[temp_UplineAddress].NumberOfChildNodeOnRight < NumberOfCurrentBalanced) {
                    NumberOfCurrentBalanced = _users[temp_UplineAddress].NumberOfChildNodeOnRight;
                }

                NumberOfNewBalanced = NumberOfCurrentBalanced - (_users[temp_UplineAddress].NumberOfBalancedCalculated + _users[temp_UplineAddress].NumberOfNewBalanced); // combine the two lline for gas lower
                
                if (NumberOfNewBalanced > 0) {
                    _users[temp_UplineAddress].NumberOfNewBalanced += NumberOfNewBalanced;

                    if (_users[temp_UplineAddress].NumberOfNewBalanced <= constMaxBalanceForCalculatedReward) {
                        totalBalance += NumberOfNewBalanced;
                        numberOfNewBalanceIn_24Hours += NumberOfNewBalanced;
                    }
                }

                temp_CurrentAddress = temp_UplineAddress;
                temp_DirectionOfCurrentNodeInUplineNode = _users[temp_CurrentAddress].DirectionOfCurrentNodeInUplineNode;
                temp_UplineAddress = _users[temp_UplineAddress].UplineAddress;
            }

            numberOfRegisteredUsersIn_24Hours += 1;
        }

        _usersAddresses.push(_msgSender());
        emit UserRegistered(uplineAddress, _msgSender());
    }

    function Upload_Old_User(address oldUserAddress) public onlyOwner {
        require(_users[oldUserAddress].Status == false , "This address is already registered!");
        require(_oldUsers[oldUserAddress] == false, "This address is already registered in old user list!");

        _oldUsers[oldUserAddress] = true;
    }

    function Today_Contract_Balance() public view returns (uint256) {
        return (70 ether) * numberOfRegisteredUsersIn_24Hours;
    }

    function All_Time_User_Left_Right(address userAddress) public view returns(uint128 ,uint128) {
        return (
            _users[userAddress].NumberOfChildNodeOnLeft,
            _users[userAddress].NumberOfChildNodeOnRight
        );
    }

    function Today_User_Balance(address userAddress) public view returns(uint256) {
        return _users[userAddress].NumberOfNewBalanced;
    }

    function Today_Total_Balance() public view returns(uint256) {
        return numberOfNewBalanceIn_24Hours;
    }

    function Today_Reward_Per_Balance() public view returns (uint256) {
        uint256 todayReward;
        if (numberOfNewBalanceIn_24Hours == 0) {
            todayReward = 0;

        } else {
            todayReward = (70 ether) * numberOfRegisteredUsersIn_24Hours / numberOfNewBalanceIn_24Hours;
        }

        return todayReward; 
    }

    function Reward_Amount_Not_Released(address userAddress) public view returns(uint256) {
        return _users[userAddress].RewardAmountNotReleased;
    }
    
    function Total_User_Reward(address userAddress) public view returns(uint256) {
        return _users[userAddress].TotalUserRewarded;
    }
    
    function User_Upline(address userAddress) public view returns(address) {
        return _users[userAddress].UplineAddress;
    }

    function User_Directs_Address(address userAddress) public view returns (address, address){
        return (
            _users[userAddress].LeftNode,
            _users[userAddress].RightNode
        );
    }

    function Registration_Fee() public view returns(uint256) {
        return registrationFee;
    }

    function User_Information(address userAddress) public view returns(Node memory) {
        return _users[userAddress];
    }

    function Total_Number_Of_Registrations() public view returns (uint256) {
        return _usersAddresses.length - 1;
    }

}