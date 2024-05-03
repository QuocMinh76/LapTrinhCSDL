# LapTrinhCSDL

I'm doing N-layers right now. I have this function to search for a person if their name contains a certain string:
public DataTable timSinhVien(string SV_NAME)
        {
            DataTable dtSearch = new DataTable();
            try
            {
                // Kết nối
                _conn.Open();
                string SQL = string.Format("SELECT * FROM SINHVIEN WHERE SV_NAME LIKE N'%{0}%'", SV_NAME);

                SqlCommand cmd = new SqlCommand(SQL, _conn);
              
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dtSearch);

            }
            catch (Exception e)
            {

            }
            finally
            {
                // Đóng kết nối
                _conn.Close();
            }

            return dtSearch;
        }
This was working fine, but today it suddenly broke. The dtSearch is always null. I've been debugging for a while and everything was passing correctly. I manually try the SQL command in SSMS as well and it return the expected results. What could be the problem and how can I fix it?
