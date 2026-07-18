import Foundation

#if DEBUG
let baseURL = URL(string: "http://localhost:3000")!
#else
let baseURL = URL(string: "https://seasonv2.onrender.com")!
#endif
