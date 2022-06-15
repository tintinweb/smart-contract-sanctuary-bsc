/**
 *Submitted for verification at BscScan.com on 2022-06-15
*/

pragma solidity 0.8.14;

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

contract MultiSender {
    address public admin; 
    mapping (address => bool) public _isWhiteListed;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not an admin");
        _;
    }

    constructor(address _admin) {
        admin = _admin; 
        _isWhiteListed[admin] = true;
    } 

    function multipletransfer(
        IBEP20 token, 
        address[] memory recivers,
        uint256[] memory amount
    ) public{
        require(_isWhiteListed[msg.sender], "only whiteList can use");
        require(recivers.length == amount.length, "unMatched Data");
        for (uint256 i; i < recivers.length; i++) {
            token.transferFrom(
                msg.sender,
                recivers[i],
                amount[i]
            );
        } 
    }
 
    function changeAdmin(address  _admin) public onlyAdmin {
        admin = _admin;
    }

    function whiteListUsers(address  user, bool _state) public onlyAdmin {
         
                 _isWhiteListed[user] =_state;
     
    }

}