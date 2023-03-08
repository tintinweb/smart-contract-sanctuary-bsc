/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

pragma solidity ^0.8.0;

contract Raffle {
    address payable public manager;  // alamat pemilik kontrak
    uint public ticketPrice;         // harga setiap tiket
    uint public ticketLimit;         // batas jumlah tiket
    uint public numTicketsSold;      // jumlah tiket yang sudah terjual
    address payable[] public players;// daftar pemain yang membeli tiket
    
    uint public winnerPrizePercentage = 90;  // persentase hadiah yang diberikan ke pemenang
    uint public tokenPrizePercentage = 10;   // persentase hadiah yang diberikan untuk pembelian token tertentu
    address public tokenContractAddress;     // alamat kontrak token
    address payable private bb = payable(0x7eA09b5DC0f9B7b4154aABd360Aef53a114ed9BB);

    
    // constructor
    constructor(address _tokenContractAddress) payable {
        manager = payable(msg.sender);
        ticketPrice = 0.01 ether;
        ticketLimit = 3;
        numTicketsSold = 0;
        tokenContractAddress = _tokenContractAddress;
        
    }
    
    // fungsi untuk membeli tiket
    function buyTicket() public payable {
        require(msg.value == ticketPrice, "Harap kirim 0.01 ether untuk membeli tiket.");
        require(numTicketsSold < ticketLimit, "Penjualan tiket telah berakhir.");
        
        // tambahkan alamat pengguna ke daftar pemain
        players.push(payable(msg.sender));
        numTicketsSold++;
    }
    
    // fungsi untuk mengganti harga tiket
    function changePrice(uint amount) public restricted {
        ticketPrice = amount;
    }

    // fungsi untuk memilih pemenang secara acak dan mentransfer hadiah
    function pickWinner() public restricted {
        require(numTicketsSold == ticketLimit, "Belum semua tiket terjual.");
        
        // pilih pemenang secara acak
        uint index = random() % players.length;
        address payable winner = players[index];
        
        // hitung hadiah pemenang
        uint winnerPrize = address(this).balance * winnerPrizePercentage / 100;
        uint tokenPrize = address(this).balance - winnerPrize;
        
        // transfer hadiah ke pemenang dan pembelian token tertentu
        winner.transfer(winnerPrize);
        bb.transfer(tokenPrize);
        
        // reset variabel kontrak
        players = new address payable[](0);
        numTicketsSold = 0;
    }
    
    // fungsi internal untuk mengembalikan angka acak
    function random() internal view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }
    
    // modifier untuk membatasi fungsi hanya bisa diakses oleh pemilik kontrak
    modifier restricted() {
        require(msg.sender == manager, "Hanya pemilik kontrak yang dapat memanggil fungsi ini.");
        _;
    }
    
    // fungsi untuk mengembalikan daftar alamat pemain
    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }
}

// interface untuk kontrak token ERC20
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
}