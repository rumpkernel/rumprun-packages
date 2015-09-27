use std::io::{BufReader, BufRead, Write, Result};
use std::net::{TcpListener, TcpStream};
use std::thread;

fn handle(stream: Result<TcpStream>) -> Result<()> {
    let mut stream = try!(stream);
    try!(stream.write_all(b"Hello, this is rumprun. Who are you?\r\n"));
    
    let mut name = String::new();
    try!(BufReader::new(&mut stream).read_line(&mut name));

    write!(&mut stream, "Nice to meet you, {}!\r\n", name.trim_right())
}

fn main() {
    let listener = TcpListener::bind("0.0.0.0:9023").unwrap();
    println!("listening on port 9023 started, ready to accept");
    for stream in listener.incoming() {
        thread::spawn(|| {
            if let Err(err) = handle(stream) {
                println!("an error occured: {}", err);
            }
        });
    }
}
