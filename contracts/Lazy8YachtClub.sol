pragma solidity ^0.8.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Lazy8YachtClub is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 private constant _maxTokens = 8888;
    uint256 private _maxPresaleTokens = 9999;
    uint256 private constant _maxMint = 9999;
    uint256 public constant _premintPrice = 180000000000000000; //0.18 ETH
    uint256 public constant _price = 180000000000000000; // 0.18 ETH
    bool private _presaleActive = false;
    bool private _saleActive = false;

    string public _prefixURI;

    mapping(address => bool) private _whitelist;

    constructor() ERC721("FAKE NAME FOR TESTING", "LIL YACHTY") {}

    function _baseURI() internal view override returns (string memory) {
        return _prefixURI;
    }

    function setBaseURI(string memory _uri) public onlyOwner {
        _prefixURI = _uri;
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }

    function setMaxPresaleTokens(uint256 newMaxPresaleMint) public onlyOwner {
        _maxPresaleTokens = newMaxPresaleMint;
    }

    function togglePreSale() public onlyOwner {
        _presaleActive = !_presaleActive;
    }

    function preSale() public view returns (bool) {
        return _presaleActive;
    }

    function Sale() public view returns (bool) {
        return _saleActive;
    }

    function toggleSale() public onlyOwner {
        _saleActive = !_saleActive;
        _presaleActive = false;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId));

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(
                        baseURI,
                        Strings.toString(tokenId),
                        ".json"
                    )
                )
                : "";
    }

    function mintItems(uint256 amount) public payable {
        require(amount <= _maxMint);
        require(_saleActive);

        uint256 totalMinted = _tokenIds.current();
        require(totalMinted + amount <= _maxTokens);

        require(msg.value >= amount * _price);

        for (uint256 i = 0; i < amount; i++) {
            _mintItem(msg.sender);
        }
    }

    function whiteListMany(address[] memory accounts) external onlyOwner {
        for (uint256 i; i < accounts.length; i++) {
            _whitelist[accounts[i]] = true;
        }
    }

    function presaleMintItems(uint256 amount) public payable {
        require(_whitelist[_msgSender()], "Mint: Unauthorized Access");
        require(amount <= _maxMint);
        require(_presaleActive);

        uint256 totalMinted = _tokenIds.current();
        require(totalMinted + amount <= _maxPresaleTokens);

        require(msg.value >= amount * _premintPrice);

        for (uint256 i = 0; i < amount; i++) {
            _mintItem(msg.sender);
        }
    }

    function _mintItem(address to) internal returns (uint256) {
        _tokenIds.increment();

        uint256 id = _tokenIds.current();
        _mint(to, id);

        return id;
    }

    function reserve(uint256 quantity) public onlyOwner {
        for(uint i = _tokenIds.current(); i < quantity; i++) {
            if (i < _maxTokens) {
                _tokenIds.increment();
                _safeMint(msg.sender, i + 1);
            }
        }
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        //CEO 20.25%
        payable(0x4b9b76fd3cE9528EE9c5e4baD883AdE536E1D8B6).transfer(balance * 2025 / 10000);
        //COO 13.50%
        payable(0x8F91E569764D9A235D8C1c912Fe5B6140254E254).transfer(balance * 1350 / 10000);
        //CMO 11.25%
        payable(0x5d2FB1BC2Dd42a74E19FBe16f4c5D7f8c0860CE3).transfer(balance * 1125 / 10000);
        //Operating Budget 55.00%
        payable(0xdA849f403fe8DDB2483eB846b8bC1529A32a6efd).transfer(balance * 5500 / 10000);
    }


}
