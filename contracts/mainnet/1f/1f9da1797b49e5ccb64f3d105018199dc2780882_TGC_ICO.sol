/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT


/*───────────────────────────────────────────────────────────────────────────────────────────────────────────
─██████████████─██████████████─██████████████────██████████████─██████████████─██████─────────██████████████─
─██░░░░░░░░░░██─██░░░░░░░░░░██─██░░░░░░░░░░██────██░░░░░░░░░░██─██░░░░░░░░░░██─██░░██─────────██░░░░░░░░░░██─
─██████░░██████─██░░██████████─██░░██████████────██░░██████████─██░░██████░░██─██░░██─────────██░░██████████─
─────██░░██─────██░░██─────────██░░██────────────██░░██─────────██░░██──██░░██─██░░██─────────██░░██─────────
─────██░░██─────██░░██─────────██░░██────────────██░░██████████─██░░██████░░██─██░░██─────────██░░██████████─
─────██░░██─────██░░██──██████─██░░██────────────██░░░░░░░░░░██─██░░░░░░░░░░██─██░░██─────────██░░░░░░░░░░██─
─────██░░██─────██░░██──██░░██─██░░██────────────██████████░░██─██░░██████░░██─██░░██─────────██░░██████████─
─────██░░██─────██░░██──██░░██─██░░██────────────────────██░░██─██░░██──██░░██─██░░██─────────██░░██─────────
─────██░░██─────██░░██████░░██─██░░██████████────██████████░░██─██░░██──██░░██─██░░██████████─██░░██████████─
─────██░░██─────██░░░░░░░░░░██─██░░░░░░░░░░██────██░░░░░░░░░░██─██░░██──██░░██─██░░░░░░░░░░██─██░░░░░░░░░░██─
─────██████─────██████████████─██████████████────██████████████─██████──██████─██████████████─██████████████─
─────────────────────────────────────────────────────────────────────────────────────────────────────────────*/
pragma solidity ^0.8.0;

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

pragma solidity ^0.8.4;

contract Ownable {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Function accessible only by the owner !!");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
}

contract TGC_ICO is Ownable {
    using Strings for uint256;
    mapping(address => uint256) Referal_Id;
    mapping(uint256 => address) public _referal_address;
    mapping(address => uint256) public Tgc_Earning;
    string private Base_url = "http://buy.thegamingcoin.com/?tgcid=";
    uint256 public Total_member = 1000;
    bool public reward_status = true;
    uint256 public Referal_Percentage = 10;
    uint256 public ExtraReward = 5000;
    uint256 public minimum_limit = 25;
    uint256 public current_Price = 1000;
    uint256 public totalRaisedAmount = 0;
    address public Admin_Wallet = 0xdCbE8cA2CFa7dA67a4E183c1579D90F4a8bf89F3;
    bool public icoStatus;

    constructor() {
       
    }

    function ChangePrice(uint256 NewPrice) external onlyOwner {
        current_Price = NewPrice;
    }

    IERC20 usdt =
        IERC20(
            address(0x55d398326f99059fF775485246999027B3197955) // usdt Token address
        );

    IERC20 TGC_TK =
        IERC20(
            address(0x5CCfC6Cba730CFD78992F3329D7129639A730d54) // TGC Token address
        );

    IERC20 Busd =
        IERC20(
            address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56) // busd Token address
        );

    function GetUser_address(uint256 _id) public view returns (address) {
        return _referal_address[_id];
    }

    function _baseURl() internal view virtual returns (string memory) {
        return Base_url;
    }

    function GetUser_Id(address _address) public view returns (uint256) {
        return Referal_Id[_address];
    }

    function Change_Url(string memory New_Url) public onlyOwner {
        Base_url = New_Url;
    }

    function Get_referal_url(address _user_address)
        public
        view
        virtual
        returns (string memory)
    {
        uint256 current_id = Referal_Id[_user_address];
        string memory currentBaseURl = _baseURl();
        return
            bytes(currentBaseURl).length > 0
                ? string(
                    abi.encodePacked(currentBaseURl, current_id.toString())
                )
                : "";
    }

    function Create_referal_url(address _user_address) internal {
            uint256 new_id = Total_member + 1;
            Referal_Id[_user_address] = new_id;
            _referal_address[new_id] = _user_address;
            Total_member = Total_member + 1;
    }


    function BuyToken_Usdt_referal(uint256 _Amount, uint256 _Referal_Id)
        public
    {
        require(!icoStatus, "tgc sale is stopped");
        require(_Amount >= 0, "sorry incorect amount");
        uint256 user_id = Referal_Id[msg.sender]; // user id here
        address referal_address = _referal_address[_Referal_Id]; // referal address here
        uint256 Usdt_Amount = _Amount * 10**18;
        uint256 referal_amount = _Amount * 10**16 * Referal_Percentage;
        if (_Referal_Id == 0) {
            if (user_id == 0) {
                usdt.transferFrom(msg.sender, Admin_Wallet, Usdt_Amount);
                TGC_TK.transfer(msg.sender, Usdt_Amount * current_Price);
                totalRaisedAmount = totalRaisedAmount + Usdt_Amount;
                Create_referal_url(msg.sender);
            } else {
                usdt.transferFrom(msg.sender, Admin_Wallet, Usdt_Amount);
                TGC_TK.transfer(msg.sender, Usdt_Amount * current_Price);
                totalRaisedAmount = totalRaisedAmount + Usdt_Amount;
            }
        } else {
            if (user_id == 0) {
                usdt.transferFrom(msg.sender, Admin_Wallet, Usdt_Amount);
                TGC_TK.transfer(
                    referal_address,
                    referal_amount * current_Price
                );
                Tgc_Earning[referal_address] = referal_amount * current_Price;
                TGC_TK.transfer(msg.sender, Usdt_Amount * current_Price);
                totalRaisedAmount = totalRaisedAmount + Usdt_Amount;
                Create_referal_url(msg.sender);
            } else {
                usdt.transferFrom(msg.sender, Admin_Wallet, Usdt_Amount);
                TGC_TK.transfer(
                    referal_address,
                    referal_amount * current_Price
                );
                Tgc_Earning[referal_address] = referal_amount * current_Price;
                TGC_TK.transfer(msg.sender, Usdt_Amount * current_Price);
                totalRaisedAmount = totalRaisedAmount + Usdt_Amount;
            }
        }
    }

    function BuyToken_Usdt_Special(uint256 _Amount, uint256 _Referal_Id)
        public
    {
        require(reward_status,"Special edition is stopped");
        require(!icoStatus, "tgc sale is stopped");
        require(_Amount >= minimum_limit, "sorry incorect amount");
        uint256 user_id = Referal_Id[msg.sender]; // user id here
        address referal_address = _referal_address[_Referal_Id]; // referal address here
        uint256 Usdt_Amount = _Amount * 10**18;
        uint256 referal_amount = _Amount * 10**16 * Referal_Percentage;
        if (_Referal_Id == 0) {
            if (user_id == 0) {
                usdt.transferFrom(msg.sender, Admin_Wallet, Usdt_Amount);
                TGC_TK.transfer(msg.sender, Usdt_Amount * (current_Price + ExtraReward));
                totalRaisedAmount = totalRaisedAmount + Usdt_Amount;
                Create_referal_url(msg.sender);
            } else {
                usdt.transferFrom(msg.sender, Admin_Wallet, Usdt_Amount);
                TGC_TK.transfer(msg.sender, Usdt_Amount * (current_Price + ExtraReward));
                totalRaisedAmount = totalRaisedAmount + Usdt_Amount;
            }
        } else {
            if (user_id == 0) {
                usdt.transferFrom(msg.sender, Admin_Wallet, Usdt_Amount);
                TGC_TK.transfer(
                    referal_address,
                    referal_amount * current_Price
                );
                Tgc_Earning[referal_address] = referal_amount * current_Price;
                TGC_TK.transfer(msg.sender, Usdt_Amount * (current_Price + ExtraReward));
                totalRaisedAmount = totalRaisedAmount + Usdt_Amount;
                Create_referal_url(msg.sender);
            } else {
                usdt.transferFrom(msg.sender, Admin_Wallet, Usdt_Amount);
                TGC_TK.transfer(
                    referal_address,
                    referal_amount * current_Price
                );
                Tgc_Earning[referal_address] = referal_amount * current_Price;
                TGC_TK.transfer(msg.sender, Usdt_Amount * (current_Price + ExtraReward));
                totalRaisedAmount = totalRaisedAmount + Usdt_Amount;
            }
        }
    }

    function BuyToken_Busd_referal(uint256 _Amount, uint256 _Referal_Id)
        public
    {
        require(!icoStatus, "tgc is stopped");
        require(_Amount >= 0, "sorry incorect amount");
        uint256 user_id = Referal_Id[msg.sender]; // user id here
        address referal_address = _referal_address[_Referal_Id]; // referal address here
        uint256 busd_Amount = _Amount * 10**18;
        uint256 referal_amount = _Amount * 10**16 * Referal_Percentage;
        if (_Referal_Id == 0) {
            if (user_id == 0) {
                Busd.transferFrom(msg.sender, Admin_Wallet, busd_Amount);
                TGC_TK.transfer(msg.sender, busd_Amount * current_Price);
                totalRaisedAmount = totalRaisedAmount + busd_Amount;
                Create_referal_url(msg.sender);
            } else {
                Busd.transferFrom(msg.sender, Admin_Wallet, busd_Amount);
                TGC_TK.transfer(msg.sender, busd_Amount * current_Price);
                totalRaisedAmount = totalRaisedAmount + busd_Amount;
            }
        } else {
            if (user_id == 0) {
                Busd.transferFrom(msg.sender, Admin_Wallet, busd_Amount);
                TGC_TK.transfer(
                    referal_address,
                    referal_amount * current_Price
                );
                Tgc_Earning[referal_address] = referal_amount * current_Price;
                TGC_TK.transfer(msg.sender, busd_Amount * current_Price);
                totalRaisedAmount = totalRaisedAmount + busd_Amount;
               Create_referal_url(msg.sender);
            } else {
                Busd.transferFrom(msg.sender, Admin_Wallet, busd_Amount);
                Tgc_Earning[referal_address] = referal_amount * current_Price;
                TGC_TK.transfer(
                    referal_address,
                    referal_amount * current_Price
                );
                TGC_TK.transfer(msg.sender, busd_Amount * current_Price);
                totalRaisedAmount = totalRaisedAmount + busd_Amount;
            }
        }
    }
    
    function BuyToken_Busd_Special(uint256 _Amount, uint256 _Referal_Id)
        public
    {
        require(reward_status,"Special edition is stopped");
        require(!icoStatus, "tgc sale is stopped");
        require(_Amount >= minimum_limit, "sorry incorect amount");
        uint256 user_id = Referal_Id[msg.sender]; // user id here
        address referal_address = _referal_address[_Referal_Id]; // referal address here
        uint256 busd_Amount = _Amount * 10**18;
        uint256 referal_amount = _Amount * 10**16 * Referal_Percentage;
        if (_Referal_Id == 0) {
            if (user_id == 0) {
                Busd.transferFrom(msg.sender, Admin_Wallet, busd_Amount);
                TGC_TK.transfer(msg.sender, busd_Amount * (current_Price + ExtraReward));
                totalRaisedAmount = totalRaisedAmount + busd_Amount;
                Create_referal_url(msg.sender);
            } else {
                Busd.transferFrom(msg.sender, Admin_Wallet, busd_Amount);
                TGC_TK.transfer(msg.sender, busd_Amount * (current_Price + ExtraReward));
                totalRaisedAmount = totalRaisedAmount + busd_Amount;
            }
        } else {
            if (user_id == 0) {
                Busd.transferFrom(msg.sender, Admin_Wallet, busd_Amount);
                TGC_TK.transfer(
                    referal_address,
                    referal_amount * current_Price
                );
                Tgc_Earning[referal_address] = referal_amount * current_Price;
                TGC_TK.transfer(msg.sender, busd_Amount * (current_Price + ExtraReward));
                totalRaisedAmount = totalRaisedAmount + busd_Amount;
               Create_referal_url(msg.sender);
            } else {
                Busd.transferFrom(msg.sender, Admin_Wallet, busd_Amount);
                Tgc_Earning[referal_address] = referal_amount * current_Price;
                TGC_TK.transfer(
                    referal_address,
                    referal_amount * current_Price
                );
                TGC_TK.transfer(msg.sender, busd_Amount * (current_Price + ExtraReward));
                totalRaisedAmount = totalRaisedAmount + busd_Amount;
            }
        }
    }

    function StopIco() external onlyOwner {
        icoStatus = true;
    }

    function ActivateIco() external onlyOwner {
        icoStatus = false;
    }

    function SpecialBuy_Switch(bool _command) public onlyOwner{
         reward_status = _command;
    }

    function Set_MinimumLimit (uint256 NewLimit) public onlyOwner{
         minimum_limit = NewLimit;
    }

    function Set_NewReward (uint256 New_Amount) public onlyOwner {
           ExtraReward = New_Amount;
    }

    function Private_sale(uint256 TGC_Ammount, address Reciver) public onlyOwner {
        TGC_TK.transfer(Reciver, TGC_Ammount * 10**18);
    }

    function change_Admin_Wallet(address _new_Admin) public onlyOwner {
        Admin_Wallet = _new_Admin;
    }
}